//
//  PaymentProgressTraineeTableViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 18/12/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps

class ConfirmationProgressTraineeTableViewController: UITableViewController {

    @IBOutlet weak var trainerImg: UIImageView!
    @IBOutlet weak var trainerNameLb: UILabel!
    
    @IBOutlet weak var courseNameLb: UILabel!
    @IBOutlet weak var courseDetailLb: UILabel!
    @IBOutlet weak var priceLb: UILabel!
    @IBOutlet weak var courseDescLb: UILabel!
    
    @IBOutlet weak var placeNameLb: UILabel!
    @IBOutlet weak var placeView: UIView!
    
    var selectedTrainer: UserProfile!
    var selectedCourse: Course!
    var selectedPlace: GMSPlace!
    var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setProfileImageRound()
        self.trainerImg.downloaded(from: self.selectedTrainer.profileImageUrl)
        self.trainerImg.accessibilityLabel = self.selectedTrainer.uid
        self.trainerImg.addGestureRecognizer(UITapGestureRecognizer (target: self, action: #selector(trainerImgTapAction(tapGesture:))))
        self.trainerNameLb.text = self.selectedTrainer.fullName
        self.trainerNameLb.accessibilityLabel = self.selectedTrainer.uid
        self.trainerNameLb.addGestureRecognizer(UITapGestureRecognizer (target: self, action: #selector(trainerImgTapAction(tapGesture:))))
        
        self.courseNameLb.text = self.selectedCourse.course
        self.courseDetailLb.text = "\(self.selectedCourse.courseLevel), \(self.selectedCourse.courseType), \(self.selectedCourse.courseLanguage), \(self.selectedCourse.timeOfCourse) times"
        self.priceLb.text = "Price: \(self.selectedCourse.coursePrice) Bath"
        self.courseDescLb.text = self.selectedCourse.courseContent
        
        self.placeNameLb.text = self.selectedPlace.name
        self.setupMapView()
    }
    
    @objc func trainerImgTapAction(tapGesture: UITapGestureRecognizer) {
        
        var uid: String!
        if let tapImg = tapGesture.view as? UIImageView {
            uid = tapImg.accessibilityLabel
        } else if let tapLabel = tapGesture.view as? UILabel {
            uid = tapLabel.accessibilityLabel
        } else {
            return
        }
        performSegue(withIdentifier: "ConfirmationProgressTraineeToProfileTrainer", sender: uid)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ConfirmationProgressTraineeToProfileTrainer" {
            
            guard let selectedTrainerForShowProfile = sender as? String else { return }
            let vc = segue.destination as! UINavigationController
            let containVc = vc.topViewController as! ProfileTrainerViewController
            containVc.isBlurProfileImage = false
            containVc.trainerProfileUid = selectedTrainerForShowProfile
        }
    }
    
    func setProfileImageRound() {
        
        self.trainerImg.layer.masksToBounds = false
        self.trainerImg.layer.cornerRadius = self.trainerImg.frame.height/2
        self.trainerImg.clipsToBounds = true
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
    
    @IBAction func cancelBtnAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.tableFooterView = UIView()
        self.setupNavigationStyle()
    }
}
