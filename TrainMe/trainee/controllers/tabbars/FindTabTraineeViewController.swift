//
//  FindTabTraineeViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 15/9/2561 BE.
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

class FindTabTraineeViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var menuBtn: UIBarButtonItem!
    @IBOutlet weak var mapContainer: UIView!
    var googleMapsView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var locationManager = CLLocationManager()
    var placeIdList = [String]()
    var ref: DatabaseReference!
    var bookPlaceDict = [String: [BookPlaceDetail]]()
    var placeList = [GMSPlace]()
    var selectedPlaceId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initSideMenu()
        
        self.ref = Database.database().reference()
        
        self.placesClient = GMSPlacesClient.shared()
        
        self.googleMapsView = GMSMapView(frame: self.view.frame)
        self.googleMapsView.isMyLocationEnabled = true
        self.googleMapsView.settings.myLocationButton = true
        self.googleMapsView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(self.googleMapsView)
        self.googleMapsView.delegate = self
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
//        self.getBookPlaceDict()
    }
    
    func getBookPlaceDict() {

        ref.child("schedule_place_books").observeSingleEvent(of: .value, with: { (snapshot) in
            let values = snapshot.value as? [String: [String: NSDictionary]]
            values?.forEach({ (placeId, eachvalue) in
                print(placeId)
                self.getPlaceDataFromPlaceId(placeId: placeId)
            })
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FindyourTrainerToShowTrainerInMarker" {
            let  vc = segue.destination as! UINavigationController
            let containVc = vc.topViewController as! ShowTrainerMarkerViewController
            containVc.placeId = self.selectedPlaceId
            
        }
    }
    
    override func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        print(marker.snippet)
        self.selectedPlaceId = marker.snippet
        performSegue(withIdentifier: "FindyourTrainerToShowTrainerInMarker", sender: self)
        return true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 15.0)
        self.googleMapsView?.animate(to: camera)
        self.locationManager.stopUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.googleMapsView.clear()
        self.setupNavigationStyle()
    }
    
    @IBAction func searchAdressBtnAction(_ sender: UIBarButtonItem) {
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
    
    func initSideMenu() {
        if self.revealViewController() != nil {
            
            self.revealViewController().rearViewRevealWidth = 275
            self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.menuBtn.target = revealViewController()
            self.menuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.getBookPlaceDict()
    }
}
