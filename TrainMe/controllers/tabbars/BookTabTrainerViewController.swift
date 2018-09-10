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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initSideMenu()
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
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickYourPlaceToAddSchedulePlace" {
            let vc = segue.destination as! UINavigationController
            let containVc = vc.topViewController as! AddSchedulePlaceViewController
            self.checkDidSelectPlace = 0
            containVc.place = place
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
        print(place.formattedAddress)
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
        
        googleMapsView.clear()
        let marker = GMSMarker(position: place.coordinate)
        marker.title = place.name
        marker.snippet = place.formattedAddress
        marker.map = googleMapsView
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
