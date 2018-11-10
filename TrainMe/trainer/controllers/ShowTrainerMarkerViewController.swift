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

class ShowTrainerMarkerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, BookDetailValueDelegate {
    
    func didRecieveValue(bookPlaceDetailTapObject: BookPlaceDetail) {

        self.bookPlaceDetailTap = bookPlaceDetailTapObject
        performSegue(withIdentifier: "ShowTrainerMarkerToShowCourseTrainerSpecified", sender: self)
    }
    
    struct trainerObject {
        var date: String!
        var bookPlaceDetail: [BookPlaceDetail]!
        var trainerList: [String]!
    }
    
    @IBOutlet weak var showTrainerTableView: UITableView!
    var ref: DatabaseReference!
    var currentUser: User?
    var selectedTrainerForShowProfile: String?
    var placeId: String!
    var trainerProfiles: [UserProfile] = []
    var trainerIdList: [String] = []
    var scheduleTimeList: [BookPlaceDetail] = []
    var selectedTrainerId: String!
    var numberOfTrainer = 0
    
    var bookPlaceDetailTap: BookPlaceDetail!
    
    var timeList: [String] = []
    var timeListSorted: [Date] = []
    var timeListSoretdString: [String] = []
    var dateList: [String] = []
    var bookPlaceDetailSorted: [BookPlaceDetail] = []
    
    var trainerObjects: [trainerObject] = []
    var buttonIdPendingAlready: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        currentUser = Auth.auth().currentUser
        
        getBookPlaceDict()
        self.getBookedDetailKey()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("xxxxxxx\(trainerObjects[section].trainerList.count)")
        return trainerObjects[section].trainerList.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return trainerObjects.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        var dateSplit = trainerObjects[section].date.split(separator: "/")
        return trainerObjects[section].date
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrainerSelected") as! TrainerSelectedTableViewCell
        var tempTimes: [BookPlaceDetail] = []
        print("555555a\(trainerObjects[indexPath.section].trainerList.count)")
        print(self.trainerObjects)

        trainerObjects[indexPath.section].bookPlaceDetail.forEach { (bookDetail) in
            if trainerObjects[indexPath.section].trainerList[indexPath.row] == bookDetail.trainerId {
                tempTimes.append(bookDetail)
            }
        }
        
        let tapGesture = UITapGestureRecognizer (target: self, action: #selector(trainerImgTapAction(tapGesture:)))
        cell.trainerImg.addGestureRecognizer(tapGesture)
        cell.delegate = self
        
        if indexPath.section == 5 {
            print("temptime: \(tempTimes)")
        }
        
        cell.setDataToCell(trainerProfile: trainerProfiles[trainerIdList.firstIndex(of: trainerObjects[indexPath.section].trainerList[indexPath.row])!], tag: indexPath.row, time: tempTimes, buttonIdPendingAlready: self.buttonIdPendingAlready)
        return cell
    }
    
    @objc func trainerImgTapAction(tapGesture: UITapGestureRecognizer) {

        let trainerTapImg = tapGesture.view as! UIImageView
        print(trainerTapImg.accessibilityLabel)
        self.selectedTrainerForShowProfile = trainerTapImg.accessibilityLabel as? String
        performSegue(withIdentifier: "SelectTrainerToShowProfile", sender: self)
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
                
                if !self.trainerIdList.contains(trainerId) {
                    self.trainerIdList.insert(trainerId, at: 0)
                }
                allBookPlaceSchedule.forEach({ (bookPlaceScheduleKey, bookPlaceScheduleValue) in
                    tempBookPlaceSchedule = BookPlaceDetail()
//                    print(bookPlaceScheduleValue["start_train_date"] as! String)
                    tempBookPlaceSchedule.key = bookPlaceScheduleKey
                    tempBookPlaceSchedule.trainerId = trainerId
                    tempBookPlaceSchedule.startTrainDate = bookPlaceScheduleValue["start_train_date"] as! String
                    tempBookPlaceSchedule.startTrainTime = bookPlaceScheduleValue["start_train_time"] as! String
                    self.scheduleTimeList.insert(tempBookPlaceSchedule, at: 0)
                    if !self.timeList.contains("\(bookPlaceScheduleValue["start_train_date"] as! String) \(bookPlaceScheduleValue["start_train_time"] as! String)") {
                        self.timeList.append("\(bookPlaceScheduleValue["start_train_date"] as! String) \(bookPlaceScheduleValue["start_train_time"] as! String)")
                    }
                })
            })
            
            self.showTrainerTableView.delegate = self
            self.showTrainerTableView.dataSource = self
            
//            self.scheduleTimeList.forEach({ print($0.getData()) })
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
//            print("@@@@@@\(value!["name"])")
            trainerProfile.fullName = value!["name"] as! String
            trainerProfile.email = value!["email"] as! String
            trainerProfile.dateOfBirth = value!["dateOfBirth"] as! String
            trainerProfile.weight = value!["weight"] as! String
            trainerProfile.height = value!["height"] as! String
            trainerProfile.gender = value!["gender"] as! String
            trainerProfile.role = value!["role"] as! String
            trainerProfile.profileImageUrl = value!["profileImageUrl"] as! String
            trainerProfile.uid = snapshot.key
            self.trainerProfiles.insert(trainerProfile, at: 0)
//            print("\(trainerProfile.getData())")
            
            if self.numberOfTrainer == self.trainerProfiles.count {
                
                self.sortDate()
                self.showTrainerTableView.reloadData()
            }
        }) { (err) in
            print(err.localizedDescription)
            self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
            return
        }
    }
    
    func getBookedDetailKey() {
        
        self.ref.child("pending_schedule_detail").observeSingleEvent(of: .value, with: { (snapshot) in
            let values = snapshot.value as? [String: [String: [String: NSDictionary]]]
            values?.forEach({ (trainerId, buttons) in
                buttons.forEach({ (buttonId, bookdetail) in
                    bookdetail.forEach({ (traineeId, bookdetailInfo) in
                        if traineeId == self.currentUser?.uid {
                            print("buttonId = \(buttonId)")
                            print("trainee = \(traineeId)")
                            self.buttonIdPendingAlready.append(buttonId)
                        }
                    })
                })
            })
        }) { (err) in
            print(err.localizedDescription)
            self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
            return
        }
    }
    
    
    func sortDate() {
        
        var convertedArray: [Date] = []
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        for dat in self.timeList {
            let date = dateFormatter.date(from: dat)
            if let date = date {
                convertedArray.append(date)
            }
        }
        
        self.timeListSorted = convertedArray.sorted(by: { $0.compare($1) == .orderedAscending })
        
        self.timeListSorted.forEach { (date) in
            self.timeListSoretdString.append(dateFormatter.string(from: date))
//            print("yyyyy\(tiemListSoretdString)")
        }
        self.matchSortedDate()

//        print(self.timeListSorted)
    }
    
    func matchSortedDate() {
        
        self.timeListSoretdString.forEach { (date) in
            self.scheduleTimeList.forEach({ (bookPlaceDetail) in
                if date == "\(bookPlaceDetail.startTrainDate) \(bookPlaceDetail.startTrainTime)" {
                    self.bookPlaceDetailSorted.append(bookPlaceDetail)
                    if !self.dateList.contains(bookPlaceDetail.startTrainDate) {
                        self.dateList.append(bookPlaceDetail.startTrainDate)
                        
                    }
                }
            })
        }
        
        print(self.dateList)
        print(self.trainerIdList)
        self.runDataFromDate()
    }
    
    func runDataFromDate() {
        print("6666\(self.trainerIdList)")
        self.dateList.forEach { self.runDataFromTrainer(date: $0) }
    }
    
    func runDataFromTrainer(date: String) {
        
        var tempBookPlaceDetailList: [BookPlaceDetail] = []
        var tempTrainerList: [String] = []
        
        self.trainerIdList.forEach { (trainerId) in
            self.bookPlaceDetailSorted.forEach({ (bookPlaceDetail) in
                if bookPlaceDetail.startTrainDate == date && bookPlaceDetail.trainerId == trainerId && trainerId != "-1" {
                    print("date: \(date): \(bookPlaceDetail.key) - \(bookPlaceDetail.startTrainTime) - \(bookPlaceDetail.trainerId)")
                    tempBookPlaceDetailList.append(bookPlaceDetail)
                    if !tempTrainerList.contains(trainerId) {
                        tempTrainerList.append(trainerId)
                    }
                }
            })
            print("pppppppppppppppp")
        }
        
        self.trainerObjects.append(trainerObject(date: date, bookPlaceDetail: tempBookPlaceDetailList, trainerList: tempTrainerList))
    }

//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
////        selectedTrainerId = trainerObjects[indexPath.section].bookPlaceDetail[indexPath.row].trainerId
//        print("$$$$$\(indexPath.section)$$$$$\(indexPath.row)")
//
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //SelectTrainerToShowProfile
        if(segue.identifier == "SelectTrainerToShowProfile") {
            let vc = segue.destination as! UINavigationController
            let containVc = vc.topViewController as! ProfileViewController
           containVc.trainerUid = self.selectedTrainerForShowProfile
        }
        if segue.identifier == "ShowTrainerMarkerToShowCourseTrainerSpecified" {
            let vc = segue.destination as! UINavigationController
            let containVc = vc.topViewController as! ShowCourseTrainerSpecifiedViewController
            containVc.bookPlaceDetail = self.bookPlaceDetailTap
            containVc.placeId = self.placeId
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
