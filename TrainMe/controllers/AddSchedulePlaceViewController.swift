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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(place.placeID)
        
        dateTf.delegate = self
        timeTf.delegate = self
        scheduleBtn.layer.cornerRadius = 5
        self.HideKeyboard()
        
        placesClient = GMSPlacesClient.shared()
        self.googleMapsView = GMSMapView(frame: self.mapContainerView.frame)
        self.googleMapsView.settings.setAllGesturesEnabled(false)
        self.googleMapsView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.scrollViewContainer.addSubview(self.googleMapsView)
        self.googleMapsView.delegate = self

        locationManager.delegate = self
        let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 17.0)
        self.googleMapsView?.animate(to: camera)
        
        createMarkerOnMapView(lat: place.coordinate.latitude, long: place.coordinate.longitude, title: "", snippet: "")

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
}
