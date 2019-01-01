//
//  OngoingProgressTrainerTableViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 19/12/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps

class OngoingProgressTrainerTableViewController: UITableViewController {

    @IBOutlet weak var traineeImg: UIImageView!
    @IBOutlet weak var traineeNameLb: UILabel!
    
    @IBOutlet weak var courseNameLb: UILabel!
    @IBOutlet weak var courseDetailLb: UILabel!
    @IBOutlet weak var priceLb: UILabel!
    @IBOutlet weak var courseDescLb: UILabel!
    
    @IBOutlet weak var placeNameLb: UILabel!
    @IBOutlet weak var placeView: UIView!
    
    var selectedTrainee: UserProfile!
    var selectedCourse: Course!
    var selectedOngoing: OngoingDetail!
    var selectedPlace: GMSPlace!
    var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setProfileImageRound()
        
        self.traineeImg.downloaded(from: self.selectedTrainee.profileImageUrl)
        self.traineeImg.accessibilityLabel = self.selectedTrainee.uid
        self.traineeImg.addGestureRecognizer(UITapGestureRecognizer (target: self, action: #selector(traineeImgTapAction(tapGesture:))))
        self.traineeNameLb.text = self.selectedTrainee.fullName
        self.traineeNameLb.accessibilityLabel = self.selectedTrainee.uid
        self.traineeNameLb.addGestureRecognizer(UITapGestureRecognizer (target: self, action: #selector(traineeImgTapAction(tapGesture:))))
        
        self.courseNameLb.text = self.selectedCourse.course
        self.courseDetailLb.text = "\(self.selectedCourse.courseLevel), \(self.selectedCourse.courseType), \(self.selectedCourse.courseLanguage), \(self.selectedCourse.timeOfCourse) times"
        self.priceLb.text = "Price: \(self.selectedCourse.coursePrice) Bath"
        self.courseDescLb.text = self.selectedCourse.courseContent
        
        self.placeNameLb.text = self.selectedPlace.name
        self.setupMapView()
    }
    
    @objc func traineeImgTapAction(tapGesture: UITapGestureRecognizer) {
        
        var uid: String!
        if let tapImg = tapGesture.view as? UIImageView {
            uid = tapImg.accessibilityLabel
        } else if let tapLabel = tapGesture.view as? UILabel {
            uid = tapLabel.accessibilityLabel
        } else {
            return
        }
        performSegue(withIdentifier: "OngoingProgressTrainerToProfileTrainee", sender: uid)
    }
    
    func setupMapView() {
        
        let camera = GMSCameraPosition.camera(withLatitude: self.selectedPlace.coordinate.latitude,
                                              longitude: self.selectedPlace.coordinate.longitude,
                                              zoom: 15.0)
        
        self.mapView = GMSMapView.map(withFrame: self.placeView.bounds, camera: camera)
        self.mapView.settings.myLocationButton = false
        self.mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.mapView.settings.setAllGesturesEnabled(false)
        self.placeView.addSubview(mapView)
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: self.selectedPlace.coordinate.latitude, longitude: self.selectedPlace.coordinate.longitude)
        marker.title = ""
        marker.snippet = ""
        marker.map = mapView
    }
    
    func setProfileImageRound() {
        
        self.traineeImg.layer.masksToBounds = false
        self.traineeImg.layer.cornerRadius = self.traineeImg.frame.height/2
        self.traineeImg.clipsToBounds = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? EachOngoingTrainerViewController {
            destination.selectedOngoing = self.selectedOngoing
        }
        
        if segue.identifier == "OngoingProgressTrainerToProfileTrainee" {
            
            guard let selectedTrainerForShowProfile = sender as? String else { return }
            let vc = segue.destination as! UINavigationController
            let containVc = vc.topViewController as! ProfileTraineeViewController
            containVc.isBlurProfile = false
            containVc.traineeProfileUid = selectedTrainerForShowProfile
        }
    }
    
    @IBAction func cancelBtnAction(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupNavigationStyle()
    }
}
