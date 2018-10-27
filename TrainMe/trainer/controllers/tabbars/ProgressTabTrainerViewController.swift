//
//  ProgressTabTrainerViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 26/8/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import SWRevealViewController
import FirebaseAuth
import FirebaseDatabase
import GooglePlaces

class ProgressTabTrainerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var menuBtn: UIBarButtonItem!

    var pendingDataLists: [[PendingBookPlaceDetail]] = []
    var ref: DatabaseReference!
    var currentUser: User!
    
    var traineeObj: [String: UserProfile] = [:]
    var traineeIds: [String] = []
    
    var placeName: [String: String] = [:]
    var placesClient: GMSPlacesClient!
    
    var courseName: [String: String] = [:]
    @IBOutlet weak var progressTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initSideMenu()
        self.title = NSLocalizedString("progress", comment: "")
        
        self.ref = Database.database().reference()
        self.currentUser = Auth.auth().currentUser
        self.placesClient = GMSPlacesClient.shared()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.traineeIds.removeAll()
        self.traineeObj.removeAll()
        self.pendingDataLists.removeAll()
        
        self.getPendingDataList()
        self.progressTableView.delegate = self
        self.progressTableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavigationStyle()
    }
    
    func getPendingDataList() {
        
        var tempPendingDatas: [PendingBookPlaceDetail] = []
        print("sadasd:\(self.currentUser.uid)")
        self.ref.child("pending_schedule_detail").child(self.currentUser.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.childrenCount > 0 {
                for pendingDataObjs in snapshot.children.allObjects as! [DataSnapshot] {
                    tempPendingDatas.removeAll()
                    let pendingDataObj = pendingDataObjs.value as! [String: NSDictionary]
                    print("aaa: \(pendingDataObj.values.count)")
                    pendingDataObj.forEach({ (pendingDataObjKey, pendingDataObjVal) in
                        print(pendingDataObjKey)
                        let pendingData = PendingBookPlaceDetail()
                        pendingData.schedule_key = pendingDataObjs.key
                        pendingData.trainee_id = pendingDataObjKey
                        pendingData.course_id = pendingDataObjVal["course_id"] as! String
                        pendingData.place_id = pendingDataObjVal["place_id"] as! String
                        pendingData.start_train_time = pendingDataObjVal["start_train_time"] as! String
                        pendingData.start_train_date = pendingDataObjVal["start_train_date"] as! String
                        tempPendingDatas.append(pendingData)
                        if self.courseName[pendingData.course_id] == nil {
                            self.getCourseData(courseId: pendingData.course_id)
                        }
                        if self.placeName[pendingData.place_id] == nil {
                            self.getPlaceData(placeId: pendingData.place_id)
                        }
//                        self.getPlaceData(placeId: pendingData.place_id)
                        if !self.traineeIds.contains(pendingData.trainee_id) {
                            self.traineeIds.append(pendingData.trainee_id)
                        }
                    })
                    self.pendingDataLists.append(tempPendingDatas)
                    if self.pendingDataLists.count == snapshot.childrenCount {
                        for traineeId in self.traineeIds {
                            self.getTraineeData(uid: traineeId)
                        }
                    }
                }
            }

            self.pendingDataLists.forEach({ (vals) in
                vals.forEach({ (val) in
                    print(val.getData())
                })
                print("=======")
            })
//            print(self.pendingDataLists)
        }) { (err) in
            print(err.localizedDescription)
            self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
            return
        }
    }
    
    func getTraineeData(uid: String) {
        
        self.ref.child("user").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let value = snapshot.value as! NSDictionary
            print(value["name"] as! String)
            let tempUserProfile = UserProfile(fullName: (value["name"] as! String), email: (value["email"] as! String), dateOfBirth: (value["dateOfBirth"] as! String), weight: (value["weight"] as! String), height: (value["height"] as! String), gender: (value["gender"] as! String), role: (value["role"] as! String), profileImageUrl: (value["profileImageUrl"] as! String), uid: uid)
            self.traineeObj[uid] = tempUserProfile
            if self.traineeObj.count == self.traineeIds.count && self.traineeObj.count != 0 {
                self.progressTableView.reloadData()
                print(self.placeName)
                print(self.courseName)
            }
//            self.progressTableView.reloadData()
        }) { (err) in
            print(err.localizedDescription)
            self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
            return
        }
    }
    
    func getPlaceData(placeId: String) {
        
        print(placeId)
        self.placesClient.lookUpPlaceID(placeId) { (place, err) in
            if let err = err {
                print("lookup place id query error: \(err.localizedDescription)")
                return
            }

            guard let place = place else {
                print("No place details for \(placeId)")
                return
            }

            self.placeName[placeId] = place.name
        }
    }
    
    func getCourseData(courseId: String) {
        
        self.ref.child("courses").child(self.currentUser.uid).child(courseId).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let value = snapshot.value as! NSDictionary
            self.courseName[courseId] = (value["course_name"] as! String)
        }) { (err) in
            print(err.localizedDescription)
            self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
            return
        }
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pendingDataLists[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return pendingDataLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProgressCell") as! ProgressTableViewCell

        cell.setDataToCell(traineeImgLink: self.traineeObj[self.pendingDataLists[indexPath.section][indexPath.row].trainee_id]!.profileImageUrl,
                           traineeName: self.traineeObj[self.pendingDataLists[indexPath.section][indexPath.row].trainee_id]!.fullName,
                           startDate: self.pendingDataLists[indexPath.section][indexPath.row].start_train_date,
                           startTime: self.pendingDataLists[indexPath.section][indexPath.row].start_train_time,
                           position: "\(indexPath.section)-\(indexPath.row)")
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.placeName[self.pendingDataLists[section][0].place_id]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func pendingSegmentedControlAction(_ sender: CustomSegmentedControl) {
        
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
}
