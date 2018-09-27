//
//  ShowTrainerMarkerViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 11/9/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import FirebaseAuth
import FirebaseDatabase

class ShowTrainerMarkerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var showTrainerTableView: UITableView!
    var ref: DatabaseReference!
    var currentUser: User?
    var placeId: String!
    var bookPlaceDict = [String: [BookPlaceDetail]]()
    var PlaceTrainerIdList = [String: [String]]()
    var trainerProfiles = [UserProfile]()
    var trainerIdList = [String]()
    var scheduleTimeList = [BookPlaceDetail]()
    var selectedTrainerId: String!
    var numberOfTrainer = 0
    
    var timeList = [String]()
    var timeListSorted = [Date]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        currentUser = Auth.auth().currentUser
        
        getBookPlaceDict()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trainerProfiles.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrainerSelected") as! TrainerSelectedTableViewCell
        cell.setDataToCell(trainerProfile: trainerProfiles.reversed()[indexPath.row])
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func getBookPlaceDict() {
        
        var tempBookPlaceSchedule: BookPlaceDetail!
        ref.child("schedule_place_books").child(self.placeId).observeSingleEvent(of: .value, with: { (snapshot) in
            let values = snapshot.value as? [String: [String: NSDictionary]]
            self.numberOfTrainer = values?.count ?? 0
            values?.forEach({ (trainerId, allBookPlaceSchedule) in
                print("qqqqqq\(trainerId)")
                self.getTrainerInfo(trainerId: trainerId)
                self.trainerIdList.append(trainerId)
                allBookPlaceSchedule.forEach({ (bookPlaceScheduleKey, bookPlaceScheduleValue) in
                    tempBookPlaceSchedule = BookPlaceDetail()
                    print(bookPlaceScheduleValue["start_train_date"] as! String)
                    tempBookPlaceSchedule.key = bookPlaceScheduleKey
                    tempBookPlaceSchedule.startTrainDate = bookPlaceScheduleValue["start_train_date"] as! String
                    tempBookPlaceSchedule.startTrainTime = bookPlaceScheduleValue["start_train_time"] as! String
                    self.scheduleTimeList.append(tempBookPlaceSchedule)
                    self.timeList.append("\(bookPlaceScheduleValue["start_train_date"] as! String) \(bookPlaceScheduleValue["start_train_time"] as! String)")
                })
            })
            
            self.showTrainerTableView.delegate = self
            self.showTrainerTableView.dataSource = self
            
            self.scheduleTimeList.forEach({ print($0.getData()) })
            self.timeList.forEach({ print($0) })
        }) { (err) in
            print(err.localizedDescription)
            self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
            return
        }
    }

    func getTrainerInfo(trainerId: String) {

        var trainerProfile = UserProfile()
        ref.child("user").child(trainerId).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            print("@@@@@@\(value!["name"])")
            trainerProfile.fullName = value!["name"] as! String
            trainerProfile.email = value!["email"] as! String
            trainerProfile.dateOfBirth = value!["dateOfBirth"] as! String
            trainerProfile.weight = value!["weight"] as! String
            trainerProfile.height = value!["height"] as! String
            trainerProfile.gender = value!["gender"] as! String
            trainerProfile.role = value!["role"] as! String
            trainerProfile.profileImageUrl = value!["profileImageUrl"] as! String
            self.trainerProfiles.append(trainerProfile)
            print(trainerProfile.getData())

            if self.numberOfTrainer == self.trainerProfiles.count {
                self.showTrainerTableView.reloadData()
                
                var convertedArray: [Date] = []
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yyyy HH:mm"// yyyy-MM-dd"
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                
                for dat in self.timeList {
                    let date = dateFormatter.date(from: dat)
                    if let date = date {
                        convertedArray.append(date)
                    }
                }
                
                self.timeListSorted = convertedArray.sorted(by: { $0.compare($1) == .orderedAscending })
                
                print(self.timeListSorted)
                
            }
        }) { (err) in
            print(err.localizedDescription)
            self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
            return
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedTrainerId = trainerIdList.reversed()[indexPath.row]
        performSegue(withIdentifier: "ShowTrainerMarkerToShowCourseTrainerSpecified", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //ShowCourseTrainerSpecifiedViewController
        if(segue.identifier == "ShowTrainerMarkerToShowCourseTrainerSpecified") {
            let vc = segue.destination as! UINavigationController
            let containVc = vc.topViewController as! ShowCourseTrainerSpecifiedViewController
            containVc.trainerId = self.selectedTrainerId
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.setupNavigationStyle()
    }
    
    @IBAction func backBtnAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}
