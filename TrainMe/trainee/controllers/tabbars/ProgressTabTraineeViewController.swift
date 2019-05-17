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
import OmiseSDK


class ProgressTabTraineeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    @IBOutlet weak var pendingTableView: UITableView!
    @IBOutlet weak var statusSegmented: UISegmentedControl!
    
    var ref: DatabaseReference!
    var currentUser: User!
    var placesClient: GMSPlacesClient!
    
    var pendingDatas: [PendingBookPlaceDetail] = []
    var pendingDataSorted: [ExpandableData] = []
    var timeListPending: [String] = []
    var timeListSortedPending: [Date] = []
    
    var paymentDatas: [PendingBookPlaceDetail] = []
    var paymentDataSorted: [PendingBookPlaceDetail] = []
    var timeListPayment: [String] = []
    var timeListSortedPayment: [Date] = []
    
    var ongoingDatas: [OngoingDetail] = []
    var ongoingDataSorted: [OngoingDetail] = []
    var waitingOngoingDataIndex: [IndexPath] = []
    var successfulDataIndex: [IndexPath] = []
    var timeListOngoing: [String] = []
    var timeListSortedOnging: [Data] = []
    
    var trainerId: [String] = []
    var trainerObj: [String: UserProfile] = [:]
    
    var courseId: [String: String] = [:] // [CourseId: TrainerId]
    var courseObj: [String: Course] = [:]
    
    var placeId: [String] = []
    var placeObj: [String: GMSPlace] = [:]
    
    var checkSortDate = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.placesClient = GMSPlacesClient.shared()
        
        self.pendingTableView.delegate = self
        self.pendingTableView.dataSource = self

        self.ref = Database.database().reference()
        self.currentUser = Auth.auth().currentUser
        
        self.initSideMenu()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        self.pendingTableView.reloadData()
        self.statusSegmented.isEnabled = false
        self.getPendingObj()
        self.getOngingData()
    }
    
    func getPendingObj() {
        
        self.ref.child("pending_schedule_detail").observe(.value, with: { (snapshot) in
            
            var isSortDate = false
            self.pendingDatas.removeAll()
            self.pendingDataSorted.removeAll()
            self.timeListPending.removeAll()
            self.timeListSortedPending.removeAll()
            self.paymentDataSorted.removeAll()
            self.paymentDatas.removeAll()
            self.timeListPayment.removeAll()
            self.timeListSortedPayment.removeAll()
            
            let values = snapshot.value as? [String: [String: [String: NSDictionary]]]
            
            values?.forEach({ (trainerId, buttons) in
                buttons.forEach({ (buttonId, bookDetail) in
                    bookDetail.forEach({ (traineeId, bookDetailInfo) in
                        if self.currentUser.uid == traineeId {
                            
                            let pendingData = PendingBookPlaceDetail()
                            pendingData.schedule_key = buttonId
                            pendingData.trainee_id = self.currentUser.uid
                            pendingData.course_id = bookDetailInfo["course_id"] as! String
                            pendingData.place_id = bookDetailInfo["place_id"] as! String
                            pendingData.start_train_time = bookDetailInfo["start_train_time"] as! String
                            pendingData.start_train_date = bookDetailInfo["start_train_date"] as! String
                            pendingData.trainer_id = trainerId
                            pendingData.is_trainer_accept = bookDetailInfo["is_trainer_accept"] as! String
                            
                            if pendingData.is_trainer_accept == "-1" {
                                
                                self.pendingDatas.append(pendingData)
                                
                                if !self.timeListPending.contains("\(pendingData.start_train_date) \(pendingData.start_train_time)") {
                                    self.timeListPending.append("\(pendingData.start_train_date) \(pendingData.start_train_time)")
                                }
                            } else if pendingData.is_trainer_accept == "1" {
                                
                                self.paymentDatas.append(pendingData)
                                if !self.timeListPayment.contains("\(pendingData.start_train_date) \(pendingData.start_train_time)") {
                                    self.timeListPayment.append("\(pendingData.start_train_date) \(pendingData.start_train_time)")
                                }
                            }
                            
                            if !self.trainerId.contains(trainerId) {
                                self.trainerId.append(trainerId)
                                isSortDate = true
                                self.checkSortDate = false
                                self.getTrainerData(trainerId: trainerId)
                            }
                            if self.courseId[bookDetailInfo["course_id"] as! String] == nil {
                                self.courseId[bookDetailInfo["course_id"] as! String] = trainerId
                                isSortDate = true
                                self.checkSortDate = false
                                self.getCourseName(trainerId: trainerId, courseId: bookDetailInfo["course_id"] as! String)
                            }
                            if !self.placeId.contains(bookDetailInfo["place_id"] as! String) {
                                self.placeId.append(bookDetailInfo["place_id"] as! String)
                                isSortDate = true
                                self.checkSortDate = false
                                self.getPlaceName(placeId: bookDetailInfo["place_id"] as! String)
                            }
                        }
                    })
                })
            })
            
            self.trainerId.forEach({ (eachTrainerId) in
                if self.trainerObj[eachTrainerId] == nil {
                    self.checkSortDate = false
                    self.getTrainerData(trainerId: eachTrainerId)
                    return
                }
            })
            self.placeId.forEach({ (eachPlaceId) in
                if self.placeObj[eachPlaceId] == nil {
                    self.checkSortDate = false
                    self.getPlaceName(placeId: eachPlaceId)
                    return
                }
            })
            self.courseId.forEach({ (eachCourseId, trainerId) in
                if self.courseObj[eachCourseId] == nil {
                    self.checkSortDate = false
                    self.getCourseName(trainerId: trainerId, courseId: eachCourseId)
                }
            })
            if !isSortDate {
                self.sortDate()
            }
        }) { (err) in
            print(err.localizedDescription)
            self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
            return
        }
    }
    
    func getOngingData() {
        
        self.ref.child("progress_schedule_detail").observe(.value, with: { (snapshot) in
            
            var tempEachOngoings: [EachOngoingDetail] = []
            let values = snapshot.value as? [String: [String: [String: AnyObject]]]
            
            self.ongoingDatas.removeAll()
            self.ongoingDataSorted.removeAll()
            self.waitingOngoingDataIndex.removeAll()
            self.successfulDataIndex.removeAll()
            self.timeListOngoing.removeAll()
            self.timeListSortedOnging.removeAll()
            
            values?.forEach({ (trainerId, traineeList) in
//                print("trainerId: \(trainerId)")
                traineeList.forEach({ (traineeId, overallScheduleDetail) in
//                    print("traineeId: \(traineeId)")
                    if traineeId == self.currentUser.uid {
                        tempEachOngoings.removeAll()
                        overallScheduleDetail.forEach({ (btnKey, detail) in
                            
                            if self.courseId[detail["course_id"] as! String] == nil {
                                self.courseId[detail["course_id"] as! String] = trainerId
                                self.checkSortDate = false
                                self.getCourseName(trainerId: trainerId, courseId: detail["course_id"] as! String)
                            }
                            
                            if !self.placeId.contains(detail["place_id"] as! String) {
                                self.placeId.append(detail["place_id"] as! String)
                                self.checkSortDate = false
                                self.getPlaceName(placeId: detail["place_id"] as! String)
                            }
                            
                            if !self.trainerId.contains(trainerId) {
                                self.trainerId.append(trainerId)
                                self.checkSortDate = false
                                self.getTrainerData(trainerId: trainerId)
                            }
                            
                            for i in 1...(Int(detail.count)-4){
                                print("courseId: \(i)")
                                let eachDetailValue = detail[String(i)] as? NSDictionary
                                let tempEachOngoing = EachOngoingDetail(start_train_date: eachDetailValue!["start_train_date"] as! String,
                                                                        start_train_time: eachDetailValue!["start_train_time"] as! String,
                                                                        status: eachDetailValue!["status"] as! String,
                                                                        count: "\(i)",
                                                                        is_trainee_confirm: eachDetailValue!["is_trainee_confirm"] as! String,
                                                                        is_trainer_confirm: eachDetailValue!["is_trainer_confirm"] as! String,
                                                                        note: eachDetailValue!["note"] as! String,
                                                                        rate_point: eachDetailValue!["rate_point"] as! String,
                                                                        review: eachDetailValue!["review"] as! String)
                                tempEachOngoings.append(tempEachOngoing)
                            }
                            
                            var tempOngoingDetail = OngoingDetail(ongoingId: btnKey,
                                                                  trainerId: trainerId,
                                                                  courseId: detail["course_id"] as! String,
                                                                  placeId: detail["place_id"] as! String,
                                                                  transactionToAdmin: detail["transaction_to_admin"] as! String,
                                                                  transactionToTrainer: detail["transaction_to_trainer"] as! String,
                                                                  eachOngoingDetails: tempEachOngoings)
                            tempOngoingDetail.traineeId = self.currentUser.uid
                            
                            self.ongoingDatas.append(tempOngoingDetail)
                            tempEachOngoings.removeAll()
                        })
                    }
                    print(self.ongoingDatas)
                })
            })
            
            for (eachOngoingIndex, eachOngoing) in self.ongoingDatas.enumerated() {
                for (eachOnGoingDetailIndex, eachOngoingDetail) in eachOngoing.eachOngoingDetails.enumerated() {
                    if eachOngoingDetail.status == "1" || eachOngoingDetail.status == "3"{
                        print("status = 1: \(eachOngoingIndex) \(eachOnGoingDetailIndex)")
                        let waitingIndexPath = IndexPath(row: eachOnGoingDetailIndex, section: eachOngoingIndex)
                        self.waitingOngoingDataIndex.append(waitingIndexPath)
                        break
                    }
                    if eachOnGoingDetailIndex+1 == eachOngoing.eachOngoingDetails.count && eachOngoingDetail.status == "2" {
                        print("status = 2: \(eachOngoingIndex)")
                        let successIndexPath = IndexPath(row: eachOnGoingDetailIndex, section: eachOngoingIndex)
                        self.successfulDataIndex.append(successIndexPath)
                    }
                }
            }
            
            self.trainerId.forEach({ (eachTrainerId) in
                if self.trainerObj[eachTrainerId] == nil {
                    self.checkSortDate = false
                    self.getTrainerData(trainerId: eachTrainerId)
                    return
                }
            })
            
            self.placeId.forEach({ (eachPlaceId) in
                if self.placeObj[eachPlaceId] == nil {
                    self.checkSortDate = false
                    self.getPlaceName(placeId: eachPlaceId)
                    return
                }
            })
            self.statusSegmented.isEnabled = true
            self.pendingTableView.reloadData()
            
        }) { (err) in
            print(err.localizedDescription)
            self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
            return
        }
    }
    
    func getTrainerData(trainerId: String) {
        
        self.ref.child("user").child(trainerId).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as! NSDictionary
            self.trainerObj[trainerId] = UserProfile(fullName: (value["name"] as! String),
                                                     email: (value["email"] as! String),
                                                     dateOfBirth: (value["dateOfBirth"] as! String),
                                                     weight: (value["weight"] as! String),
                                                     height: (value["height"] as! String),
                                                     gender: (value["gender"] as! String),
                                                     role: (value["role"] as! String),
                                                     profileImageUrl: (value["profileImageUrl"] as! String),
                                                     omiseCusId: (value["omise_cus_id"] as! String),
                                                     ban: (value["ban"] as! Bool))
            self.trainerObj[trainerId]?.uid = trainerId
            
            if self.trainerId.count == self.trainerObj.count && self.trainerId.count != 0 &&
                self.courseId.count == self.courseObj.count && self.courseId.count != 0 &&
                self.placeId.count == self.placeObj.count && self.placeId.count != 0 && !self.checkSortDate {
                self.sortDate()
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

            self.courseObj[courseId] = Course(key: snapshot.key,
                                               course: value["course_name"] as! String,
                                               courseContent: value["course_content"] as! String,
                                               courseVideoUrl: value["course_video_url"]  as! String,
                                               courseType: value["course_type"] as! String,
                                               timeOfCourse: value["time_of_course"] as! String,
                                               courseDuration: value["course_duration"] as! String,
                                               courseLevel: value["course_level"] as! String,
                                               coursePrice: value["course_price"] as! String,
                                               courseLanguage: value["course_language"] as! String)
            
            if self.trainerId.count == self.trainerObj.count && self.trainerId.count != 0 &&
                self.courseId.count == self.courseObj.count && self.courseId.count != 0 &&
                self.placeId.count == self.placeObj.count && self.placeId.count != 0 && !self.checkSortDate {
                self.sortDate()
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
            
            self.placeObj[placeId] = place
            
            if self.trainerId.count == self.trainerObj.count && self.trainerId.count != 0 &&
                self.courseId.count == self.courseObj.count && self.courseId.count != 0 &&
                self.placeId.count == self.placeObj.count && self.placeId.count != 0 && !self.checkSortDate {
                self.sortDate()
            }
        }
    }
    
    func sortDate() {
        
        self.checkSortDate = true
        
        var convertedArrayPending: [Date] = []
        var convertedArrayPayment: [Date] = []
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        for dat in self.timeListPending {
            let date = dateFormatter.date(from: dat)
            if let date = date {
                convertedArrayPending.append(date)
            }
        }
        
        for dat in self.timeListPayment {
            let date = dateFormatter.date(from: dat)
            if let date = date {
                convertedArrayPayment.append(date)
            }
        }
        
        self.timeListSortedPending = convertedArrayPending.sorted(by: { $0.compare($1) == .orderedAscending })
        self.timeListSortedPayment = convertedArrayPayment.sorted(by: { $0.compare($1) == .orderedAscending })
        self.matchPendingAndDate()
    }
    
    func matchPendingAndDate() {
        
        var tempPendingDetail: [PendingBookPlaceDetail] = []
        self.timeListSortedPending.forEach { (date) in
            tempPendingDetail.removeAll()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy HH:mm"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            let result = formatter.string(from: date)
            self.pendingDatas.forEach({ (pendingBookDetail) in
                if result == "\(pendingBookDetail.start_train_date) \(pendingBookDetail.start_train_time)" {
                    tempPendingDetail.append(pendingBookDetail)
                    self.pendingDatas.remove(at: self.pendingDatas.firstIndex(where: {$0 === pendingBookDetail})!)
                    print("@@@@@@@@@")
                }
            })
            self.pendingDataSorted.append(ExpandableData(isExpanded: true, date: "\(result)", pendingDetail: tempPendingDetail))
            print("pendingeiei: \(self.pendingDataSorted)")
        }
        
        self.timeListSortedPayment.forEach { (date) in
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy HH:mm"
            formatter.locale = Locale(identifier: "en_US_POSFIX")
            let result = formatter.string(from: date)
            self.paymentDatas.forEach({ (pendingBookDetail) in
                if result == "\(pendingBookDetail.start_train_date) \(pendingBookDetail.start_train_time)" {
                    self.paymentDataSorted.append(pendingBookDetail)
                    self.paymentDatas.remove(at: self.paymentDatas.firstIndex(where: {$0 === pendingBookDetail})!)
                }
            })
        }
        
        self.paymentDataSorted.forEach { (a) in
            print("------- \(a.getData())")
        }
        self.pendingTableView.reloadData()
        self.statusSegmented.isEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "progress".localized()
        self.statusSegmented.setTitle("confirm_progress".localized(), forSegmentAt: 0)
        self.statusSegmented.setTitle("payment_progress".localized(), forSegmentAt: 1)
        self.statusSegmented.setTitle("ongoing_progress".localized(), forSegmentAt: 2)
        self.statusSegmented.setTitle("successful_progress".localized(), forSegmentAt: 3)
        
        self.pendingTableView.tableFooterView = UIView()
        
        self.setupNavigationStyle()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch self.statusSegmented.selectedSegmentIndex {
        case 0:
            if !self.pendingDataSorted[section].isExpanded {
                return 0
            }
            return self.pendingDataSorted[section].pendingDetail.count
        case 1:
            return self.paymentDataSorted.count
        case 2:
            return self.waitingOngoingDataIndex.count
        case 3:
            return self.successfulDataIndex.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch self.statusSegmented.selectedSegmentIndex {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TraineeConfirmationTableViewCell") as! ConfirmationTableViewCell
            
            cell.setDataToCell(trainerProfileUrl: (self.trainerObj[self.pendingDataSorted[indexPath.section].pendingDetail[indexPath.row].trainer_id]?.profileImageUrl)!,
                               name: (self.trainerObj[self.pendingDataSorted[indexPath.section].pendingDetail[indexPath.row].trainer_id]?.fullName)!,
                               courseName: self.courseObj[self.pendingDataSorted[indexPath.section].pendingDetail[indexPath.row].course_id]!.course,
                               placeName: self.placeObj[self.pendingDataSorted[indexPath.section].pendingDetail[indexPath.row].place_id]!.name,
                               position: "\(indexPath.section)-\(indexPath.row)")
            
            cell.trainerProfileImg.accessibilityElements = [(self.trainerObj[self.pendingDataSorted[indexPath.section].pendingDetail[indexPath.row].trainer_id]?.uid)!, false]
            cell.trainerProfileImg.addGestureRecognizer(UITapGestureRecognizer (target: self, action: #selector(trainerImgTapAction(tapGesture:))))
            cell.nameLb.accessibilityElements = [(self.trainerObj[self.pendingDataSorted[indexPath.section].pendingDetail[indexPath.row].trainer_id]?.uid)!, false]
            cell.nameLb.addGestureRecognizer(UITapGestureRecognizer (target: self, action: #selector(trainerImgTapAction(tapGesture:))))
            cell.cancelBtn.addTarget(self, action: #selector(self.cancelBtnAction(cancelBtn:)), for: .touchUpInside)
            cell.cancelBtn.setTitleColor(UIColor.red, for: .normal)
            cell.cancelBtn.setTitle("cancel".localized(), for: .normal)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TraineePaymentTableViewCell") as! PaymentTraineeTableViewCell
            
            cell.setDataToCell(trainerProfileUrl: (self.trainerObj[self.paymentDataSorted[indexPath.row].trainer_id]?.profileImageUrl)!,
                               name: (self.trainerObj[self.paymentDataSorted[indexPath.row].trainer_id]?.fullName)!,
                               courseName: self.courseObj[self.paymentDataSorted[indexPath.row].course_id]!.course,
                               placeName: self.placeObj[self.paymentDataSorted[indexPath.row].place_id]!.name,
                               time: "\(self.paymentDataSorted[indexPath.row].start_train_date) \(self.paymentDataSorted[indexPath.row].start_train_time)",
                               position: "\(indexPath.section)-\(indexPath.row)")
            
            cell.trainerImg.accessibilityElements = [(self.trainerObj[self.paymentDataSorted[indexPath.row].trainer_id]?.uid)!, false]
            cell.trainerImg.addGestureRecognizer(UITapGestureRecognizer (target: self, action: #selector(trainerImgTapAction(tapGesture:))))
            cell.trainerNameLb.accessibilityElements = [(self.trainerObj[self.paymentDataSorted[indexPath.row].trainer_id]?.uid)!, false]
            cell.trainerNameLb.addGestureRecognizer(UITapGestureRecognizer (target: self, action: #selector(trainerImgTapAction(tapGesture:))))
            cell.buyBtn.setTitle("pay".localized(), for: .normal)
//            cell.buyBtn.addTarget(self, action: #selector(self.paymentAction(buyBtn:)), for: .touchUpInside)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TraineeOngingTableViewCell") as! OngoingTraineeTableViewCell
        
            cell.setDataToCell(trainerProfileUrl: (self.trainerObj[self.ongoingDatas[self.waitingOngoingDataIndex[indexPath.row].section].trainerId]?.profileImageUrl)!,
                               trainerName: (self.trainerObj[self.ongoingDatas[self.waitingOngoingDataIndex[indexPath.row].section].trainerId]?.fullName)!,
                               courseName: (self.courseObj[self.ongoingDatas[self.waitingOngoingDataIndex[indexPath.row].section].courseId]?.course)!,
                               time: "[\(self.ongoingDatas[self.waitingOngoingDataIndex[indexPath.row].section].eachOngoingDetails[self.waitingOngoingDataIndex[indexPath.row].row].count)]",
                               scheduleDate: "\(self.ongoingDatas[self.waitingOngoingDataIndex[indexPath.row].section].eachOngoingDetails[self.waitingOngoingDataIndex[indexPath.row].row].start_train_date) \(self.ongoingDatas[self.waitingOngoingDataIndex[indexPath.row].section].eachOngoingDetails[self.waitingOngoingDataIndex[indexPath.row].row].start_train_time)",
                placeName: self.placeObj[self.ongoingDatas[self.waitingOngoingDataIndex[indexPath.row].section].placeId]!.name)
            
            cell.trainerImg.accessibilityElements = [(self.trainerObj[self.ongoingDatas[self.waitingOngoingDataIndex[indexPath.row].section].trainerId]?.uid)!, false]
            cell.trainerImg.addGestureRecognizer(UITapGestureRecognizer (target: self, action: #selector(trainerImgTapAction(tapGesture:))))
            cell.trainerNameLb.accessibilityElements = [(self.trainerObj[self.ongoingDatas[self.waitingOngoingDataIndex[indexPath.row].section].trainerId]?.uid)!, false]
            cell.trainerNameLb.addGestureRecognizer(UITapGestureRecognizer (target: self, action: #selector(trainerImgTapAction(tapGesture:))))
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TraineeSuccessfulTableViewCell") as! SuccessfulTraineeTableViewCell
            
            cell.setDataToCell(trainerProfileUrl: (self.trainerObj[self.ongoingDatas[self.successfulDataIndex[indexPath.row].section].trainerId]?.profileImageUrl)!,
                               trainerName: (self.trainerObj[self.ongoingDatas[self.successfulDataIndex[indexPath.row].section].trainerId]?.fullName)!,
                               courseName: (self.courseObj[self.ongoingDatas[self.successfulDataIndex[indexPath.row].section].courseId]?.course)!,
                               placeName: self.placeObj[self.ongoingDatas[self.successfulDataIndex[indexPath.row].section].placeId]!.name,
                               time: "\(self.ongoingDatas[self.successfulDataIndex[indexPath.row].section].eachOngoingDetails[self.successfulDataIndex[indexPath.row].row].start_train_date) \(self.ongoingDatas[self.successfulDataIndex[indexPath.row].section].eachOngoingDetails[self.successfulDataIndex[indexPath.row].row].start_train_time)")
            
            cell.trainerImg.accessibilityElements = [(self.trainerObj[self.ongoingDatas[self.successfulDataIndex[indexPath.row].section].trainerId]?.uid)!, false]
            cell.trainerImg.addGestureRecognizer(UITapGestureRecognizer (target: self, action: #selector(trainerImgTapAction(tapGesture:))))
            cell.trainerNameLb.accessibilityElements = [(self.trainerObj[self.ongoingDatas[self.successfulDataIndex[indexPath.row].section].trainerId]?.uid)!, false]
            cell.trainerNameLb.addGestureRecognizer(UITapGestureRecognizer (target: self, action: #selector(trainerImgTapAction(tapGesture:))))
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    @objc func trainerImgTapAction(tapGesture: UITapGestureRecognizer) {
        
        var dataToTrainerProfile: [Any]!
        if let tapImg = tapGesture.view as? UIImageView {
            dataToTrainerProfile = tapImg.accessibilityElements!
            //            dataToTraineeProfile.append(tapImg.accessibilityElements![0] as! String)
            //            dataToTraineeProfile.append(tapImg.accessibilityElements![1] as! Bool)
        } else if let tapLabel = tapGesture.view as? UILabel {
            dataToTrainerProfile = tapLabel.accessibilityElements!
            //            uid = tapLabel.accessibilityLabel
            //            dataToTraineeProfile.append(tapLabel.accessibilityElements![0] as! String)
            //            dataToTraineeProfile.append(tapLabel.accessibilityElements![1] as! Bool)
        } else {
            return
        }
        performSegue(withIdentifier: "ProgressTraineeToProfileTrainer", sender: dataToTrainerProfile)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switch self.statusSegmented.selectedSegmentIndex {
        case 0:
            print("0: \(indexPath)")
            performSegue(withIdentifier: "ProgressToConfirmation", sender: indexPath)
        case 1:
            print("1: \(indexPath)")
            performSegue(withIdentifier: "ProgressToConfirmation", sender: indexPath)
        case 2:
            print("2: \(indexPath)")
            performSegue(withIdentifier: "ProgressToOngoing", sender: indexPath)
        case 3:
            print("3: \(indexPath)")
            performSegue(withIdentifier: "ProgressToOngoing", sender: indexPath)
        default:
            return
        }
    }
    
    @objc func cancelBtnAction(cancelBtn: UIButton) {
        
        let cencelIndexPath = IndexPath(row: Int(cancelBtn.accessibilityLabel!.components(separatedBy: "-")[1])!, section: Int(cancelBtn.accessibilityLabel!.components(separatedBy: "-")[0])!)
        
        let alert = UIAlertController(title: "cancel_this_course".localized(), message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "confirm".localized(), style: .default, handler: { (action) in
            
            self.view.showBlurLoader()
            self.tabBarController?.tabBar.isHidden = true
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            
            self.deletePendingData(deletePendingIndexPath: cencelIndexPath)
        }))
        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func paymentAction(buyBtn: UIButton) {
    
        performSegue(withIdentifier: "PayToSelectCreditCard", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == "PayToSelectCreditCard") {
            guard let buyBtn = sender as? UIButton else {
                print("not btn")
                return
            }
            
            let payIndexPath = IndexPath(row: Int((buyBtn.accessibilityLabel?.components(separatedBy: "-")[1])!)!, section: Int((buyBtn.accessibilityLabel?.components(separatedBy: "-")[0])!)!)
            let vc = segue.destination as! UINavigationController
            let containVc = vc.topViewController as! SelectCreditCardToChargeViewController
            containVc.selectedCourse = self.courseObj[self.paymentDataSorted[payIndexPath.row].course_id]
            containVc.pendingData = self.paymentDataSorted[payIndexPath.row]
        }
        
        if segue.identifier == "ProgressToOngoing" {
            
            guard let indexPath = sender as? IndexPath else {
                print("not indexpath")
                return
            }
            
            switch self.statusSegmented.selectedSegmentIndex {
            case 2:
                let vc = segue.destination as! UINavigationController
                let containVc = vc.topViewController as! OngoingProgressTraineeTableViewController
                containVc.selectedTrainer = self.trainerObj[self.ongoingDatas[self.waitingOngoingDataIndex[indexPath.row].section].trainerId]
                containVc.selectedCourse = self.courseObj[self.ongoingDatas[self.waitingOngoingDataIndex[indexPath.row].section].courseId]
                containVc.selectedOngoing = self.ongoingDatas[self.waitingOngoingDataIndex[indexPath.row].section]
                containVc.selectedPlace = self.placeObj[self.ongoingDatas[self.waitingOngoingDataIndex[indexPath.row].section].placeId]!
                containVc.navigationController?.topViewController?.title  = "ongoing_progress".localized()
                print("ProgressToOngoing: \(self.waitingOngoingDataIndex[indexPath.row])")
            case 3:
                let vc = segue.destination as! UINavigationController
                let containVc = vc.topViewController as! OngoingProgressTraineeTableViewController
                containVc.navigationController?.topViewController?.title = "Successful progress"
                containVc.selectedTrainer = self.trainerObj[self.ongoingDatas[self.successfulDataIndex[indexPath.row].section].trainerId]
                containVc.selectedCourse = self.courseObj[self.ongoingDatas[self.successfulDataIndex[indexPath.row].section].courseId]
                containVc.selectedOngoing = self.ongoingDatas[self.successfulDataIndex[indexPath.row].section]
                containVc.selectedPlace = self.placeObj[self.ongoingDatas[self.successfulDataIndex[indexPath.row].section].placeId]
                containVc.navigationController?.topViewController?.title = "successful_progress".localized()
                print("ProgressToSuccessful: \(self.successfulDataIndex[indexPath.row])")
            default:
                return
            }
        }
        
        if segue.identifier == "ProgressToConfirmation" {
            
            guard let indexPath = sender as? IndexPath else {
                print("not indexpath")
                return
            }
            
            switch self.statusSegmented.selectedSegmentIndex {
            case 0:
                let vc = segue.destination as! UINavigationController
                let containVc = vc.topViewController as! ConfirmationProgressTraineeTableViewController
                containVc.selectedTrainer = self.trainerObj[self.pendingDataSorted[indexPath.section].pendingDetail[indexPath.row].trainer_id]
                containVc.selectedCourse = self.courseObj[self.pendingDataSorted[indexPath.section].pendingDetail[indexPath.row].course_id]
                containVc.selectedPlace = self.placeObj[self.pendingDataSorted[indexPath.section].pendingDetail[indexPath.row].place_id]
                containVc.navigationController?.topViewController?.title = "confirm_progress".localized()
                print("ProgressToConfirmation")
            case 1:
                let vc = segue.destination as! UINavigationController
                let containVc = vc.topViewController as! ConfirmationProgressTraineeTableViewController
                containVc.selectedTrainer = self.trainerObj[self.paymentDataSorted[indexPath.row].trainer_id]
                containVc.selectedCourse = self.courseObj[self.paymentDataSorted[indexPath.row].course_id]
                containVc.selectedPlace = self.placeObj[self.paymentDataSorted[indexPath.row].place_id]
                containVc.navigationController?.topViewController?.title = "payment_progress".localized()
                print("ProgressToPayment")
            default:
                return
            }
        }

        if segue.identifier == "ProgressTraineeToProfileTrainer" {
            
            guard let selectedTrainerForShowProfile = sender as? [Any] else { return }
            let vc = segue.destination as! UINavigationController
            let containVc = vc.topViewController as! ProfileTrainerViewController
            containVc.isBlurProfileImage = (selectedTrainerForShowProfile[1] as! Bool)
            containVc.trainerProfileUid = (selectedTrainerForShowProfile[0] as! String)
        }
    }
    
    @objc func dismissCreditCardForm() {
        
        self.dismiss(animated: true, completion: nil)
    }

    func deletePendingData(deletePendingIndexPath: IndexPath) {
            
            let deletePendingData = self.pendingDataSorted[deletePendingIndexPath.section].pendingDetail[deletePendingIndexPath.row]
            
            self.ref.child("pending_schedule_detail").child(deletePendingData.trainer_id).child(deletePendingData.schedule_key).child(self.currentUser.uid).removeValue { (err, ref) in
                
                if let err = err {
                    self.view.removeBluerLoader()
                    self.tabBarController?.tabBar.isHidden = false
                    self.navigationController?.setNavigationBarHidden(false, animated: true)
                    print(err.localizedDescription)
                    self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                    return
                }
                
                self.addNotificationDatabase(toUid: deletePendingData.trainer_id, description: "Your trainee was canceled your confirmation")
                
//                self.pendingDataSorted[deletePendingIndexPath.section].pendingDetail.remove(at: deletePendingIndexPath.row)
//                if self.pendingDataSorted[deletePendingIndexPath.section].pendingDetail.count == 0 {
//                    self.pendingDataSorted.remove(at: deletePendingIndexPath.section)
//                }
//                self.pendingTableView.reloadData()
            }
         
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch self.statusSegmented.selectedSegmentIndex {
        case 0:
            return self.pendingDataSorted[section].date
        case 1:
            return "wait_your_trainee_for_pay".localized()
        case 2:
            return "ongoing_schedule".localized()
        case 3:
            return "successful_schedule".localized()
        default:
            return ""
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch self.statusSegmented.selectedSegmentIndex {
        case 0:
            return self.pendingDataSorted.count
        case 1:
            return 1
        case 2:
            return 1
        case 3:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        switch self.statusSegmented.selectedSegmentIndex {
        case 0:
            let headerBtn = UIButton(type: .system)
            headerBtn.setTitle("close".localized(), for: .normal)
            headerBtn.setTitleColor(.black, for: .normal)
            headerBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            headerBtn.addTarget(self, action: #selector(self.handleExpandCollapse(headerBtn:)), for: .touchUpInside)
            headerBtn.tag = section
            headerBtn.translatesAutoresizingMaskIntoConstraints = false
            
            let label = UILabel()
            label.text = self.pendingDataSorted[section].date
            label.font = UIFont.boldSystemFont(ofSize: 14.0)
            label.numberOfLines = 1
            label.translatesAutoresizingMaskIntoConstraints = false
            
            let view = UIView()
            view.backgroundColor = UIColor.clear
            view.addSubview(label)
            view.addSubview(headerBtn)
            
            let views = ["label": label, "button": headerBtn, "view": view]
            
            let horizontallayoutContraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[label(<=250)]-0-[button]-|", options: .alignAllCenterY, metrics: nil, views: views)
            view.addConstraints(horizontallayoutContraints)
            
            let verticalLayoutContraint = NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
            view.addConstraint(verticalLayoutContraint)
            
            return view
        case 1:
            let label = UILabel()
            label.text = "please_select_your_course_to_pay".localized()
            label.font = UIFont.boldSystemFont(ofSize: 14.0)
            label.numberOfLines = 1
            label.translatesAutoresizingMaskIntoConstraints = false
            
            let view = UIView()
            view.backgroundColor = UIColor.clear
            view.addSubview(label)
            
            let views = ["label": label, "view": view]
            
            let horizontallayoutContraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[label(<=250)]-|", options: .alignAllCenterY, metrics: nil, views: views)
            view.addConstraints(horizontallayoutContraints)
            
            let verticalLayoutContraint = NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
            view.addConstraint(verticalLayoutContraint)
            
            return view
        case 2:
            let label = UILabel()
            label.text = "ongoing_schedule".localized()
            label.font = UIFont.boldSystemFont(ofSize: 14.0)
            label.numberOfLines = 1
            label.translatesAutoresizingMaskIntoConstraints = false
            
            let view = UIView()
            view.backgroundColor = UIColor.clear
            view.addSubview(label)
            
            let views = ["label": label, "view": view]
            
            let horizontallayoutContraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[label(<=250)]-|", options: .alignAllCenterY, metrics: nil, views: views)
            view.addConstraints(horizontallayoutContraints)
            
            let verticalLayoutContraint = NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
            view.addConstraint(verticalLayoutContraint)
            
            return view
        case 3:
            let label = UILabel()
            label.text = "successful_schedule".localized()
            label.font = UIFont.boldSystemFont(ofSize: 14.0)
            label.numberOfLines = 1
            label.translatesAutoresizingMaskIntoConstraints = false
            
            let view = UIView()
            view.backgroundColor = UIColor.clear
            view.addSubview(label)
            
            let views = ["label": label, "view": view]
            
            let horizontallayoutContraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[label(<=250)]-|", options: .alignAllCenterY, metrics: nil, views: views)
            view.addConstraints(horizontallayoutContraints)
            
            let verticalLayoutContraint = NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
            view.addConstraint(verticalLayoutContraint)
            
            return view
        default:
            return UIView()
        }
    }
    
    @objc func handleExpandCollapse(headerBtn: UIButton) {
     
        let section = headerBtn.tag
        
        var indexPaths = [IndexPath]()
        for row in self.pendingDataSorted[section].pendingDetail.indices {
            let indexPath = IndexPath(row: row, section: section)
            indexPaths.append(indexPath)
        }
        
        let isExpanded = self.pendingDataSorted[section].isExpanded
        self.pendingDataSorted[section].isExpanded = !isExpanded
        
        headerBtn.setTitle(isExpanded ? "open".localized() : "close".localized(), for: .normal)
        
        if isExpanded {
            self.pendingTableView.deleteRows(at: indexPaths, with: .fade)
        } else {
            self.pendingTableView.insertRows(at: indexPaths, with: .fade)
        }
        
        print("indexPaths: \(indexPaths)")
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
    

    
    @IBAction func progressSegmentedControl(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            // Confirmation
            self.pendingTableView.reloadData()
        }
        if sender.selectedSegmentIndex == 1 {
            // Payment
            self.pendingTableView.reloadData()
        }
        if sender.selectedSegmentIndex == 2 {
            // Ongoing
            self.pendingTableView.reloadData()
        }
        if sender.selectedSegmentIndex == 3 {
            // Successful
            self.pendingTableView.reloadData()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func addNotificationDatabase(toUid: String, description: String) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        dateFormatter.locale = Locale(identifier: "en")
        let fromDate = dateFormatter.string(from: Date())
        print(fromDate)
        
        let notificationData = ["from_uid": self.currentUser.uid,
                                "description": description,
                                "timestamp": Date().getCurrentTime(),
                                "is_read": "0",
                                "is_report": "0"]
        
        self.ref.child("notifications").child(toUid).childByAutoId().updateChildValues(notificationData) { (err, ref) in
            if let err = err {
                self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                print(err.localizedDescription)
                return
            }
            self.view.removeBluerLoader()
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.tabBarController?.tabBar.isHidden = false
        }
    }
}
