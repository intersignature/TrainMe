//
//  BookTabViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 26/8/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import SWRevealViewController
import FirebaseAuth
import FirebaseDatabase
import GoogleMaps
import GooglePlaces
import GooglePlacePicker
import CoreLocation

class BookTabTrainerViewController: UIViewController, UISearchBarDelegate, GMSPlacePickerViewControllerDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    @IBOutlet weak var mapContainer: UIView!
    
    var googleMapsView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var locationManager = CLLocationManager()
    var placePicker: GMSPlacePickerViewController!
    var checkDidSelectPlace = 0
    var place: GMSPlace!
    var bookPlaceDict = [String: [BookPlaceDetail]]()
    var ref: DatabaseReference!
    var currentUser: User?
    var placeIdList = [String]()
    var placeList = [GMSPlace]()
    var PlaceTrainerIdList = [String: [String]]() // [placeId: [trainerId]]
    var selectedPlaceId: String!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initSideMenu()
        
        ref = Database.database().reference()
        currentUser = Auth.auth().currentUser
        
        self.title = NSLocalizedString("pick_your_place", comment: "")
        
        placesClient = GMSPlacesClient.shared()

        self.googleMapsView = GMSMapView(frame: self.view.frame)
        self.googleMapsView.isMyLocationEnabled = true
        self.googleMapsView.settings.myLocationButton = true
        self.googleMapsView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(self.googleMapsView)
        self.googleMapsView.delegate = self

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        getBookPlaceDict()
        
//        bookPlaceDict.forEach { (key, bookDetails) in
//            print(key)
//            bookDetails.forEach({ (bookDetail) in
//                print(bookDetail.getData())
//            })
//            print("---")
//        }
    }
    
//    func getTrainerIdList() { // [placeId: [trainerId]]
//        var tempTrainerId = [String]()
//
//        placeIdList.forEach { (placeId) in
//            tempTrainerId = []
//            bookPlaceDict.forEach({ (trainerId, bookPlaceDetails) in
//
//                bookPlaceDetails.forEach({ (bookPlaceDetail) in
//
//                    if placeId == bookPlaceDetail.placeId {
//
//                        if !tempTrainerId.contains(trainerId){
//                            tempTrainerId.append(trainerId)
//                        }
//                    }
//                })
//            })
//            PlaceTrainerIdList[placeId] = tempTrainerId
//        }
//    }
    
    func getBookPlaceDict() {
//        self.googleMapsView.clear()
        self.placeIdList = []
        ref.child("schedule_place_books").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? [String: [String: NSDictionary]]
            value?.forEach({ (key, eachValue) in
                var bookPlaceDetails = [BookPlaceDetail]()
                eachValue.forEach({ (bookPlaceKey, bookPlaceValue) in
                    let bookPlaceDetail = BookPlaceDetail(key: bookPlaceKey, placeId: bookPlaceValue["place_id"] as! String, startTrainDate: bookPlaceValue["start_train_date"] as! String, startTrainTime: bookPlaceValue["start_train_time"] as! String)
                    bookPlaceDetails.append(bookPlaceDetail)
                })
                self.bookPlaceDict[key] = bookPlaceDetails
            })

            self.bookPlaceDict.forEach({ (key, bookPlaceDetails) in
//                print("\(key)")
                bookPlaceDetails.forEach({ (bookPlaceDetail) in
//                    print("\(bookPlaceDetail.getData())\n^^^^^^^^^^^^^^^")

                    if !self.placeIdList.contains(bookPlaceDetail.placeId) {
                        self.placeIdList.append(bookPlaceDetail.placeId)
                        self.getPlaceDataFromPlaceId(placeId: bookPlaceDetail.placeId)
                        print(bookPlaceDetail.placeId)
                    }
                })
//                print("------------------------")
            })
//            self.getTrainerIdList()
        }) { (err) in
            print(err.localizedDescription)
            self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
            return
        }
    }
    
    func getPlaceDataFromPlaceId(placeId: String) {
        placesClient.lookUpPlaceID(placeId) { (place, err) in
            if let err = err {
                print(err.localizedDescription)
                self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                return
            }
            
            guard let place = place else {
                print("No place details for \(placeId)")
                self.createAlert(alertTitle: "No place details for \(placeId)", alertMessage: "")
                return
            }
            
            self.createMarkerOnMapView(lat: place.coordinate.latitude, long: place.coordinate.longitude, title: "", snippet: place.placeID)
            self.placeList.append(place)
//            print("Place name \(place.name)")
//            print("Place address \(place.formattedAddress)")
//            print("Place placeID \(place.placeID)")
//            print("Place attributions \(place.attributions)")
//            print("---------")

        }

    }
    
    func createMarkerOnMapView(lat: CLLocationDegrees, long: CLLocationDegrees, title: String, snippet: String) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
        marker.title = title
        marker.snippet = snippet
//        marker.setValue(trainerId, forKeyPath: "trainerId")
//        marker.setValue(trainerId, forUndefinedKey: "trainerId")
        marker.map = googleMapsView
    }
    
    override func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
//        print(marker.value(forKey: "trainerId") as! String)
        PlaceTrainerIdList[marker.snippet!]?.forEach({ print("^^^^^\($0)^^^^")})
        self.selectedPlaceId = marker.snippet
        performSegue(withIdentifier: "PickYourPlaceToShowTrainerInMarker", sender: self)
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickYourPlaceToAddSchedulePlace" {
            let vc = segue.destination as! UINavigationController
            let containVc = vc.topViewController as! AddSchedulePlaceViewController
            self.checkDidSelectPlace = 0
            containVc.place = place
        }
        if segue.identifier == "PickYourPlaceToShowTrainerInMarker" {
            let vc = segue.destination as! UINavigationController
            let containVc = vc.topViewController as! ShowTrainerMarkerViewController
            containVc.placeId = self.selectedPlaceId
        }
    }
    
    @IBAction func bookPlaceTrainerBtnAction(_ sender: UIBarButtonItem) {
        let config = GMSPlacePickerConfig(viewport: nil)
        placePicker = GMSPlacePickerViewController(config: config)

        placePicker.setupNavigationStyle()
        placePicker.delegate = self

        self.present(placePicker, animated: true, completion: nil)
    }
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        checkDidSelectPlace = 0
        self.dismiss(animated: true, completion: nil)
    }
    
    func placePicker(_ viewController: GMSPlacePickerViewController, didFailWithError error: Error) {
        checkDidSelectPlace = 0
        self.createAlert(alertTitle: error.localizedDescription, alertMessage: "")
    }
    
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        
        self.place = place
        checkDidSelectPlace = 1
//        print("^^^^^^^\(place.name)^^^^^^^")
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func cancelPlacePickerAction() {
        print("dasdasdas")
        //        self.dismiss(animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 15.0)
        self.googleMapsView?.animate(to: camera)
        self.locationManager.stopUpdatingLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if checkDidSelectPlace == 1 {
            print("selected place")
            performSegue(withIdentifier: "PickYourPlaceToAddSchedulePlace", sender: self)
        } else if checkDidSelectPlace == 0 {
            getBookPlaceDict()
            print("not selected place")
        }
//        checkDidSelectPlace ?? 0 {print("seleect place")} else {print("not select place")}
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        checkDidSelectPlace = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.googleMapsView.clear()
        setupNavigationStyle()
    }
    
    @IBAction func serachAddressBtnAction(_ sender: UIBarButtonItem) {
        
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
        let filter = GMSAutocompleteFilter()
        filter.type = .noFilter
        autocompleteController.autocompleteFilter = filter
        
        present(autocompleteController, animated: true, completion: nil)
    }
    
    override func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
//        googleMapsView.clear()
//        let marker = GMSMarker(position: place.coordinate)
//        marker.title = place.name
//        marker.snippet = place.formattedAddress
//        marker.map = googleMapsView
//        self.createMarkerOnMapView(lat: place.coordinate.latitude, long: place.coordinate.longitude, title: place.name, snippet: place.formattedAddress!)
        googleMapsView.animate(toLocation: place.coordinate)
        googleMapsView.animate(toZoom: 15.0)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initSideMenu() {
        if revealViewController() != nil {
            
            revealViewController().rearViewRevealWidth = 275
            self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            menuBtn.target = revealViewController()
            menuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
        }
    }
}
