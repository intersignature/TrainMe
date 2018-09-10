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
    @IBOutlet weak var dateTf: DTTextField!
    @IBOutlet weak var timeTf: DTTextField!
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
        dateFormatter.dateFormat = "MM/dd/yyyy"
    
        dateTf.text = dateFormatter.string(from: datePicker.date)
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
        let doneBtn = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.dismissKeyboard))
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
        
        self.setupNavigationStyle()
    }
    
    @IBAction func cancelBtnAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func scheduleBtnAction(_ sender: UIButton) {
        
        let date = dateTf.text ?? ""
        let time = timeTf.text ?? ""
        

        if !checkData(date: date, time: time){
            self.createAlert(alertTitle: "Please fill in the blank", alertMessage: "")
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
        
        let dictionaryValues = ["place_id": place.placeID,
                                "start_train_date": date,
                                "start_train_time": time]
        
        ref.child("schedule_place_books").child(uid).childByAutoId().updateChildValues(dictionaryValues) { (err, ref) in
            if let err = err {
                print(err.localizedDescription)
                self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                return
            }
            print("successfully add schedule place book to database")
            self.dismiss(animated: true, completion: nil)
        }
    }
}
