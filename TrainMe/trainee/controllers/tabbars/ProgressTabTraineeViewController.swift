//
//  ProgressTabTraineeViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 15/9/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import SWRevealViewController
import FirebaseAuth
import FirebaseDatabase
import GooglePlaces

class ProgressTabTraineeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    @IBOutlet weak var pendingTableView: UITableView!
    
    var ref: DatabaseReference!
    var currentUser: User!
    var placesClient: GMSPlacesClient!
    
    var pendingData: [PendingBookPlaceDetail] = []
    
    var trainerId: [String] = []
    var trainerObj: [String: UserProfile] = [:]
    
    var courseId: [String] = []
    var courseName: [String: String] = [:]
    
    var placeId: [String] = []
    var placeName: [String: String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.placesClient = GMSPlacesClient.shared()
        
        self.pendingTableView.delegate = self
        self.pendingTableView.dataSource = self

        self.ref = Database.database().reference()
        self.currentUser = Auth.auth().currentUser
        
        self.initSideMenu()
        
        self.getPendingObj()
    }

    func getPendingObj() {
        
        self.ref.child("pending_schedule_detail").observeSingleEvent(of: .value, with: { (snapshot) in
            let values = snapshot.value as? [String: [String: [String: NSDictionary]]]
            values?.forEach({ (trainerId, buttons) in
                buttons.forEach({ (buttonId, bookDetail) in
                    bookDetail.forEach({ (traineeId, bookDetailInfo) in
                        if self.currentUser.uid == traineeId {
                            print("\(trainerId) - \(bookDetailInfo["start_train_date"] as! String) - \(bookDetailInfo["start_train_time"] as! String)")
                            self.pendingData.append(PendingBookPlaceDetail(trainer_id: trainerId,
                                                                           course_id: bookDetailInfo["course_id"] as! String,
                                                                           place_id: bookDetailInfo["place_id"] as! String,
                                                                           start_train_date: bookDetailInfo["start_train_date"] as! String,
                                                                           start_train_time: bookDetailInfo["start_train_time"] as! String,
                                                                           schedule_key: buttonId))
                            
                            if !self.trainerId.contains(trainerId) {
                                self.trainerId.append(trainerId)
                                self.getTrainerData(trainerId: trainerId)
                            }
                            if !self.courseId.contains(bookDetailInfo["course_id"] as! String) {
                                self.courseId.append(bookDetailInfo["course_id"] as! String)
                                self.getCourseName(trainerId: trainerId, courseId: bookDetailInfo["course_id"] as! String)
                            }
                            if !self.placeId.contains(bookDetailInfo["place_id"] as! String) {
                                self.placeId.append(bookDetailInfo["place_id"] as! String)
                                self.getPlaceName(placeId: bookDetailInfo["place_id"] as! String)
                            }
                        }
                    })
                })
            })
            self.pendingData.forEach({ (pendingBookDetail) in
                print(pendingBookDetail.getData())
                print("=======================================")
            })
        }) { (err) in
            print(err.localizedDescription)
            self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
            return
        }
    }
    
    func getTrainerData(trainerId: String) {
        
        ref.child("user").child(trainerId).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as! NSDictionary
            self.trainerObj[trainerId] = UserProfile(fullName: (value["name"] as! String),
                                                     email: (value["email"] as! String),
                                                     dateOfBirth: (value["dateOfBirth"] as! String),
                                                     weight: (value["weight"] as! String),
                                                     height: (value["height"] as! String),
                                                     gender: (value["gender"] as! String),
                                                     role: (value["role"] as! String),
                                                     profileImageUrl: (value["profileImageUrl"] as! String))
            
            if self.trainerId.count == self.trainerObj.count && self.trainerId.count != 0 &&
                self.courseId.count == self.courseName.count && self.courseId.count != 0 &&
                self.placeId.count == self.placeName.count && self.placeId.count != 0 {
                self.pendingTableView.reloadData()
            }
        }) { (err) in
            print(err.localizedDescription)
            self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
            return
        }
    }
    
    func getCourseName(trainerId: String, courseId: String) {
        
        ref.child("courses").child(trainerId).child(courseId).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as! NSDictionary
            self.courseName[courseId] = (value["course_name"] as! String)
            
            if self.trainerId.count == self.trainerObj.count && self.trainerId.count != 0 &&
                self.courseId.count == self.courseName.count && self.courseId.count != 0 &&
                self.placeId.count == self.placeName.count && self.placeId.count != 0 {
                self.pendingTableView.reloadData()
            }
        }) { (err) in
            print(err.localizedDescription)
            self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
            return
        }
    }
    
    func getPlaceName(placeId: String) {
        
        self.placesClient.lookUpPlaceID(placeId) { (place, err) in
            if let err = err {
                print(err.localizedDescription)
                self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                return
            }
            
            guard let place = place else {
                print("No place details for \(placeId)")
                return
            }
            
            self.placeName[placeId] = place.name
            
            if self.trainerId.count == self.trainerObj.count && self.trainerId.count != 0 &&
                self.courseId.count == self.courseName.count && self.courseId.count != 0 &&
                self.placeId.count == self.placeName.count && self.placeId.count != 0 {
                self.pendingTableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupNavigationStyle()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pendingData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TraineeConfirmationTableViewCell") as! ConfirmationTableViewCell
        cell.setDataToCell(trainerProfileUrl: (self.trainerObj[self.pendingData[indexPath.row].trainer_id]?.profileImageUrl)!,
                           name: (self.trainerObj[self.pendingData[indexPath.row].trainer_id]?.fullName)!,
                           startDate: self.pendingData[indexPath.row].start_train_date,
                           startTime: self.pendingData[indexPath.row].start_train_time,
                           courseName: self.courseName[self.pendingData[indexPath.row].course_id]!,
                           placeName: self.placeName[self.pendingData[indexPath.row].place_id]!)
        return cell
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
    
    @IBAction func progressCustomSegmentedControl(_ sender: CustomSegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            // Confirmation
        }
        if sender.selectedSegmentIndex == 1 {
            // Payment
        }
        if sender.selectedSegmentIndex == 2 {
            // Ongoing
        }
        if sender.selectedSegmentIndex == 3 {
            // Successful
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
