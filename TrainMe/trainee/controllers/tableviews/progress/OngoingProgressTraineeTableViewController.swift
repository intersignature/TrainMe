//
//  OngoingProgressTraineeTableViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 5/12/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps

class OngoingProgressTraineeTableViewController: UITableViewController {
    
    @IBOutlet weak var trainerImg: UIImageView!
    @IBOutlet weak var trainerNameLb: UILabel!
    
    @IBOutlet weak var coureNameLb: UILabel!
    @IBOutlet weak var courseDetailLb: UILabel!
    @IBOutlet weak var coursePrice: UILabel!
    @IBOutlet weak var courseDescLb: UILabel!
    
    @IBOutlet weak var placeNameLb: UILabel!
    @IBOutlet weak var placeMapView: UIView!
    
    var selectedTrainer: UserProfile!
    var selectedCourse: Course!
    var selectedOngoing: OngoingDetail!
    var selectedPlace: GMSPlace!
    var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 600
        
        self.setProfileImageRound()
        
        self.trainerImg.downloaded(from: self.selectedTrainer.profileImageUrl)
        self.trainerNameLb.text = self.selectedTrainer.fullName
        self.coureNameLb.text = self.selectedCourse.course
        self.courseDetailLb.text = "\(self.selectedCourse.courseLevel), \(self.selectedCourse.courseType), \(self.selectedCourse.courseLanguage), \(self.selectedCourse.timeOfCourse) times"
        self.coursePrice.text = "\(self.selectedCourse.coursePrice) Bath"
        self.courseDescLb.text = self.selectedCourse.courseContent
        self.placeNameLb.text = self.selectedPlace.name
        self.setMapView()
        
        print("selectedOngoing: \(self.selectedOngoing.eachOngoingDetails)")
        print("selectedCourse: \(self.selectedCourse.getData())")
    }
    
    func setProfileImageRound() {
        
        self.trainerImg.layer.masksToBounds = false
        self.trainerImg.layer.cornerRadius = self.trainerImg.frame.height/2
        self.trainerImg.clipsToBounds = true
    }
    
    func setMapView() {
        let camera = GMSCameraPosition.camera(withLatitude: self.selectedPlace.coordinate.latitude,
                                              longitude: self.selectedPlace.coordinate.longitude,
                                              zoom: 15.0)
        
        self.mapView = GMSMapView.map(withFrame: self.placeMapView.bounds, camera: camera)
        self.mapView.settings.myLocationButton = false
        self.mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.mapView.settings.setAllGesturesEnabled(false)
        self.placeMapView.addSubview(mapView)
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: self.selectedPlace.coordinate.latitude, longitude: self.selectedPlace.coordinate.longitude)
        marker.title = ""
        marker.snippet = ""
        marker.map = mapView
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destination = segue.destination as? EachOngoingTraineeViewController {
            destination.selectedOngoing = self.selectedOngoing
        }
        
        if(segue.identifier == "EachOngoingProgressToReview") {
            let vc = segue.destination as! UINavigationController
            let containVc = vc.topViewController as! ReviewTrainerByTraineeViewController
            let index = sender as! Int
            containVc.trainerId = self.selectedTrainer.uid
            containVc.ongoingId = self.selectedOngoing.ongoingId
            containVc.countAtIndex = self.selectedOngoing.eachOngoingDetails[index].count
            containVc.summaryCount = String(self.selectedOngoing.eachOngoingDetails.count)
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
