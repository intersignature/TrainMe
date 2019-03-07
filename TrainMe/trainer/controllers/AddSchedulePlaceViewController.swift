//
//  AddSchedulePlaceViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 10/9/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import DTTextField
import FirebaseAuth
import FirebaseDatabase

class AddSchedulePlaceViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {

    @IBOutlet weak var scrollViewContainer: UIView!
    @IBOutlet weak var mapContainerView: UIView!
    var googleMapsView: GMSMapView!
    var place: GMSPlace!
    var placesClient: GMSPlacesClient!
    var locationManager = CLLocationManager()
    @IBOutlet weak var dateTf: UITextField!
    @IBOutlet weak var timeTf: UITextField!
    @IBOutlet weak var scheduleBtn: UIButton!
    
    var ref: DatabaseReference!
    var currentUser: User?
    
    var datePicker: UIDatePicker!
    var timePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("place id = \(place.placeID)")
        
        ref = Database.database().reference()
        currentUser = Auth.auth().currentUser

        dateTf.delegate = self
        timeTf.delegate = self
        scheduleBtn.layer.cornerRadius = 5
        self.HideKeyboard()
        
        self.placesClient = GMSPlacesClient.shared()
        self.googleMapsView = GMSMapView(frame: self.mapContainerView.frame)
        self.googleMapsView.settings.setAllGesturesEnabled(false)
        self.googleMapsView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.scrollViewContainer.addSubview(self.googleMapsView)
        self.googleMapsView.delegate = self

        locationManager.delegate = self
        let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 17.0)
        self.googleMapsView?.animate(to: camera)
        
        createMarkerOnMapView(lat: place.coordinate.latitude, long: place.coordinate.longitude, title: "", snippet: "")

        setupDatePicker()
        setupTimePicker()
        createPickerToolbar()
    }
    
    func setupDatePicker() {
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateChange(datePicker:)), for: .valueChanged)
        
        dateTf.inputView = datePicker
    }
    
    func setupTimePicker() {
        timePicker = UIDatePicker()
        timePicker.datePickerMode = .time
        timePicker.addTarget(self, action: #selector(timeChange(datePicker:)), for: .valueChanged)
        
        timeTf.inputView = timePicker
    }
    
    
    @objc func dateChange(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en")
        dateFormatter.setLocalizedDateFormatFromTemplate("dd/MM/yyyy")
    
        let tempDate = dateFormatter.string(from: datePicker.date).split(separator: "/")
        dateTf.text = "\(tempDate[1])/\(tempDate[0])/\(tempDate[2])"
    }
    
    @objc func timeChange(datePicker: UIDatePicker) {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        timeTf.text = timeFormatter.string(from: timePicker.date)
    }
    
    @IBAction func dateTfAction(_ sender: DTTextField) {
        if dateTf.text == "" {
            print("datetfaction")
        }
    }
    
    func createPickerToolbar() {
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneBtn = UIBarButtonItem(title: "done".localized(), style: .plain, target: self, action: #selector(self.dismissKeyboard))
        toolbar.setItems([doneBtn], animated: false)
        toolbar.isUserInteractionEnabled = true
        dateTf.inputAccessoryView = toolbar
        timeTf.inputAccessoryView = toolbar
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dateTf.resignFirstResponder()
        timeTf.resignFirstResponder()
        return true
    }
    
    func createMarkerOnMapView(lat: CLLocationDegrees, long: CLLocationDegrees, title: String, snippet: String) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
        marker.title = title
        marker.snippet = snippet
        marker.map = googleMapsView
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 15.0)
        self.googleMapsView?.animate(to: camera)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
   
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
//        self.setupNavigationStyle()
        self.setLocalizeText()
    }
    
    func setLocalizeText() {
        
        title = "add_schedule".localized()
        self.dateTf.attributedPlaceholder = NSAttributedString(string: "fill_in_start_date".localized(), attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        self.timeTf.attributedPlaceholder = NSAttributedString(string: "fill_in_start_time".localized(), attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        self.scheduleBtn.setTitle("confirm".localized(), for: .normal)
    }
    
    @IBAction func cancelBtnAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func scheduleBtnAction(_ sender: UIButton) {
        
        self.view.showBlurLoader()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        let date = dateTf.text ?? ""
        let time = timeTf.text ?? ""
        

        if !checkData(date: date, time: time){
            self.view.removeBluerLoader()
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.createAlert(alertTitle: "please_fill_in_the_blank".localized(), alertMessage: "")
            return
        }
        
        addScheduleToDatabase(date: date, time: time)
    }
    
    func checkData(date: String, time: String) -> Bool {
        if date == "" || time == "" {
            return false
        }
        return true
    }
    
    func addScheduleToDatabase(date: String, time: String) {
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        let scheduleDetailDicVal = ["start_train_date": date,
                                    "start_train_time": time]
        
        ref.child("schedule_place_books").child(place.placeID).child(uid).childByAutoId().updateChildValues(scheduleDetailDicVal) { (err, ref) in
            self.view.removeBluerLoader()
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            if let err = err {
                print(err.localizedDescription)
                self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                return
            }
            
            print("successfully add schedule place book to database")
            let alert = UIAlertController(title: "successfully_add_schedule_place_book_to_database".localized(), message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: { (action) in
                 self.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
