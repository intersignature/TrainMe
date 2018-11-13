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

struct ExpandableData {
    
    var isExpanded: Bool
    var date: String
    var pendingDetail: [PendingBookPlaceDetail]
}

class ProgressTabTrainerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var statusSegmented: CustomSegmentedControl!
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    @IBOutlet weak var progressTableView: UITableView!
    
    var pendingDataListsMatch: [ExpandableData] = []
    var pendingDetails: [PendingBookPlaceDetail] = []
    var pendingTimeList: [String] = []
    var pendingTimeListSorted: [Date] = []
    
    var paymentDataListsMatch: [PendingBookPlaceDetail] = []
    var paymentDetail: [PendingBookPlaceDetail] = []
    var paymentTimeList: [String] = []
    var paymentTimeListSorted: [Date] = []
    
    var ref: DatabaseReference!
    var currentUser: User!
    var placesClient: GMSPlacesClient!
    
    var traineeObj: [String: UserProfile] = [:]
    var traineeIds: [String] = []
    
    var placeName: [String: String] = [:]
    var placeIds: [String] = []
    
    var courseObj: [String: Course] = [:]
    var courseIds: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initSideMenu()
        self.title = NSLocalizedString("progress", comment: "")
        
        self.ref = Database.database().reference()
        self.currentUser = Auth.auth().currentUser
        self.placesClient = GMSPlacesClient.shared()
        
        self.progressTableView.delegate = self
        self.progressTableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.pendingDataListsMatch.removeAll()
        self.pendingDetails.removeAll()
        self.pendingTimeList.removeAll()
        self.pendingTimeListSorted.removeAll()
        self.traineeObj.removeAll()
        self.traineeIds.removeAll()
        self.placeName.removeAll()
        self.placeIds.removeAll()
        self.courseObj.removeAll()
        self.courseIds.removeAll()
        
        self.getPendingDataList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavigationStyle()
    }
    
    func getPendingDataList() {

        print("sadasd:\(self.currentUser.uid)")
        self.ref.child("pending_schedule_detail").child(self.currentUser.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.childrenCount > 0 {
                for pendingDataObjs in snapshot.children.allObjects as! [DataSnapshot] {
//                    print("pendingobjscount: \(pendingDataObjs.childrenCount)")
                    let pendingDataObj = pendingDataObjs.value as! [String: NSDictionary]
//                    print("aaa: \(pendingDataObj.values.count)")
                    pendingDataObj.forEach({ (pendingDataObjKey, pendingDataObjVal) in
                        
//                        print(pendingDataObjKey)
                        let pendingData = PendingBookPlaceDetail()
                        pendingData.schedule_key = pendingDataObjs.key
                        pendingData.trainee_id = pendingDataObjKey
                        pendingData.course_id = pendingDataObjVal["course_id"] as! String
                        pendingData.place_id = pendingDataObjVal["place_id"] as! String
                        pendingData.start_train_time = pendingDataObjVal["start_train_time"] as! String
                        pendingData.start_train_date = pendingDataObjVal["start_train_date"] as! String
                        pendingData.trainer_id = self.currentUser.uid
                        pendingData.is_trainer_accept = pendingDataObjVal["is_trainer_accept"] as! String
                        
                        if pendingData.is_trainer_accept == "-1" {
                            
                            self.pendingDetails.append(pendingData)
                            
                            if !self.pendingTimeList.contains("\(pendingData.start_train_date) \(pendingData.start_train_time)") {
                                self.pendingTimeList.append("\(pendingData.start_train_date) \(pendingData.start_train_time)")
                            }
                        } else if pendingData.is_trainer_accept == "1" {
                            
                            self.paymentDetail.append(pendingData)
                            
                            if !self.paymentTimeList.contains("\(pendingData.start_train_date) \(pendingData.start_train_time)") {
                                self.paymentTimeList.append("\(pendingData.start_train_date) \(pendingData.start_train_time)")
                            }
                        }
                        
                        if !self.courseIds.contains(pendingData.course_id) {
                            self.courseIds.append(pendingData.course_id)
                            self.getCourseData(courseId: pendingData.course_id)
                        }
                        if !self.placeIds.contains(pendingData.place_id){
                            self.placeIds.append(pendingData.place_id)
                            self.getPlaceData(placeId: pendingData.place_id)
                        }
                        if !self.traineeIds.contains(pendingData.trainee_id) {
                            self.traineeIds.append(pendingData.trainee_id)
                            self.getTraineeData(uid: pendingData.trainee_id)
                        }
                    })
                }
                
            }
//            if self.pendingDetailsCount == self.pendingDetails.count {
//                self.progressTableView.reloadData()
//            }
            
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
            if self.traineeObj.count == self.traineeIds.count && self.traineeObj.count != 0 &&
                self.courseObj.count == self.courseIds.count && self.courseObj.count != 0 &&
                self.placeName.count == self.placeIds.count && self.placeName.count != 0 {
                self.sortDate()
            }
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
                self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                print("lookup place id query error: \(err.localizedDescription)")
                return
            }

            guard let place = place else {
                print("No place details for \(placeId)")
                return
            }

            self.placeName[placeId] = place.name
            
            if self.traineeObj.count == self.traineeIds.count && self.traineeObj.count != 0 &&
                self.courseObj.count == self.courseIds.count && self.courseObj.count != 0 &&
                self.placeName.count == self.placeIds.count && self.placeName.count != 0 {
                self.sortDate()
            }
        }
    }
    
    func getCourseData(courseId: String) {
        
        self.ref.child("courses").child(self.currentUser.uid).child(courseId).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let value = snapshot.value as! NSDictionary
//            self.courseName[courseId] = (value["course_name"] as! String)
            let course = Course(key: courseId,
                                course: (value["course_name"] as! String),
                                courseContent: (value["course_content"] as! String),
                                courseType: (value["course_type"] as! String),
                                timeOfCourse: (value["time_of_course"] as! String),
                                courseDuration: (value["course_duration"] as! String),
                                courseLevel: (value["course_level"] as! String),
                                coursePrice: (value["course_price"] as! String),
                                courseLanguage: (value["course_language"] as! String))
            self.courseObj[courseId] = course
            if self.traineeObj.count == self.traineeIds.count && self.traineeObj.count != 0 &&
                self.courseObj.count == self.courseIds.count && self.courseObj.count != 0 &&
                self.placeName.count == self.placeIds.count && self.placeName.count != 0 {
                self.sortDate()
            }
        }) { (err) in
            print(err.localizedDescription)
            self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
            return
        }
    }
    
    
    func sortDate() {
        
        var convertedArrayPending: [Date] = []
        var convertedArrayPayment: [Date] = []
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        for dat in self.pendingTimeList {
            let date = dateFormatter.date(from: dat)
            if let date = date {
                convertedArrayPending.append(date)
            }
        }
        
        for dat in self.paymentTimeList {
            let date = dateFormatter.date(from: dat)
            if let date = date {
                convertedArrayPayment.append(date)
            }
        }
        
        self.pendingTimeListSorted = convertedArrayPending.sorted(by: { $0.compare($1) == .orderedAscending })
        self.paymentTimeListSorted = convertedArrayPayment.sorted(by: { $0.compare($1) == .orderedAscending })
        self.matchPendingAndDate()
    }
    
    func matchPendingAndDate() {
        
        var tempPendingDetail: [PendingBookPlaceDetail] = []
        self.pendingTimeListSorted.forEach { (date) in
            tempPendingDetail.removeAll()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy HH:mm"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            let result = formatter.string(from: date)
            self.pendingDetails.forEach({ (pendingBookDetail) in
                if result == "\(pendingBookDetail.start_train_date) \(pendingBookDetail.start_train_time)" {
                    tempPendingDetail.append(pendingBookDetail)
                    self.pendingDetails.remove(at: self.pendingDetails.firstIndex(where: {$0 === pendingBookDetail})!)
                    print("hhhhhhh")
                    print(self.pendingDetails)
                }
            })
            self.pendingDataListsMatch.append(ExpandableData(isExpanded: true, date: "\(result)", pendingDetail: tempPendingDetail))
        }
        
        self.paymentTimeListSorted.forEach { (date) in
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy HH:mm"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            let result = formatter.string(from: date)
            self.paymentDetail.forEach({ (pendingBookDetail) in
                if result == "\(pendingBookDetail.start_train_date) \(pendingBookDetail.start_train_time)" {
                    self.paymentDataListsMatch.append(pendingBookDetail)
                    self.paymentDetail.remove(at: self.paymentDetail.firstIndex(where: {$0 === pendingBookDetail})!)
                }
            })
        }
        
        self.paymentDataListsMatch.forEach { (a) in
            print("********* \(a.getData())")
        }
        
        self.progressTableView.reloadData()
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
        
        switch self.statusSegmented.selectedSegmentIndex {
        case 0:
            if !self.pendingDataListsMatch[section].isExpanded {
                return 0
            }
            return self.pendingDataListsMatch[section].pendingDetail.count
        case 1:
            return 1
        default:
            return 0
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        
        switch self.statusSegmented.selectedSegmentIndex {
        case 0:
            return self.pendingDataListsMatch.count
        case 1:
            return self.paymentDataListsMatch.count
        default:
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch self.statusSegmented.selectedSegmentIndex {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProgressCell") as! ProgressTableViewCell
            
            cell.setDataToCell(traineeImgLink: self.traineeObj[self.pendingDataListsMatch[indexPath.section].pendingDetail[indexPath.row].trainee_id]!.profileImageUrl,
                               traineeName: self.traineeObj[self.pendingDataListsMatch[indexPath.section].pendingDetail[indexPath.row].trainee_id]!.fullName,
                               courseName: self.courseObj[self.pendingDataListsMatch[indexPath.section].pendingDetail[indexPath.row].course_id]!.course,
                               placeName: self.placeName[self.pendingDataListsMatch[indexPath.section].pendingDetail[indexPath.row].place_id]!,
                               position: "\(indexPath.section)-\(indexPath.row)")
            
            cell.acceptBtn.isHidden = false
            cell.declineBtn.isHidden = false
            
            cell.acceptBtn.addTarget(self, action: #selector(self.acceptBtnAction(acceptBtn:)), for: .touchUpInside)
            cell.declineBtn.addTarget(self, action: #selector(self.declineBtnAction(declineBtn:)), for: .touchUpInside)
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProgressCell") as! ProgressTableViewCell
            
            cell.setDataToCell(traineeImgLink: (self.traineeObj[self.paymentDataListsMatch[indexPath.row].trainee_id]?.profileImageUrl)!,
                               traineeName: (self.traineeObj[self.paymentDataListsMatch[indexPath.row].trainee_id]?.fullName)!,
                               courseName: (self.courseObj[self.paymentDataListsMatch[indexPath.row].course_id]?.course)!,
                               placeName: self.placeName[self.paymentDataListsMatch[indexPath.row].place_id]!,
                               position: "\(indexPath.section)-\(indexPath.row)")
            
            cell.acceptBtn.isHidden = true
            cell.declineBtn.isHidden = true
            
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    @objc func acceptBtnAction(acceptBtn: UIButton) {
        
        let acceptIndexPath = IndexPath(row: Int(acceptBtn.accessibilityLabel!.components(separatedBy: "-")[1])!, section: Int(acceptBtn.accessibilityLabel!.components(separatedBy: "-")[0])!)
        
        let alert = UIAlertController(title: "Accept?", message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) in
            
            self.view.showBlurLoader()
            self.tabBarController?.tabBar.isHidden = true
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            
            print("Accept OK at pos: section: \(acceptIndexPath.section) row: \(acceptIndexPath.row)")
            print(self.pendingDataListsMatch[acceptIndexPath.section].pendingDetail[acceptIndexPath.row].trainer_id)
 
            //payment zone
//            self.addProgressData(pendingData: self.pendingDataListsMatch[acceptIndexPath.section].pendingDetail[acceptIndexPath.row])
            
            self.changeTrainerAcceptStatus(indexPath: acceptIndexPath)
//            self.deleteSchedulePlaceBook(pendingData: self.pendingDataListsMatch[acceptIndexPath.section].pendingDetail[acceptIndexPath.row])
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func declineBtnAction(declineBtn: UIButton) {
        
        let declineIndexPath = IndexPath(row: Int(declineBtn.accessibilityLabel!.components(separatedBy: "-")[1])!, section: Int(declineBtn.accessibilityLabel!.components(separatedBy: "-")[0])!)
        
        let alert = UIAlertController(title: "Decline?", message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) in
            
            self.view.showBlurLoader()
            self.tabBarController?.tabBar.isHidden = true
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            
            print("Decline OK at pos: section: \(declineIndexPath.section) row: \(declineIndexPath.row)")
            self.deletePendingData(indexPath: declineIndexPath, from: "decline")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func changeTrainerAcceptStatus(indexPath: IndexPath) {
        
        let changeTrainerPending = self.pendingDataListsMatch[indexPath.section].pendingDetail[indexPath.row]
        
        let changeData = ["is_trainer_accept": "1"]
        
        self.ref.child("pending_schedule_detail").child(changeTrainerPending.trainer_id).child(changeTrainerPending.schedule_key).child(changeTrainerPending.trainee_id).updateChildValues(changeData) { (err, ref) in
            
            if let err = err {
                print(err.localizedDescription)
                self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                return
            }
            self.pendingDataListsMatch[indexPath.section].pendingDetail.remove(at: indexPath.row)
            
            if self.pendingDataListsMatch[indexPath.section].pendingDetail.count == 0 {
                self.pendingDataListsMatch.remove(at: indexPath.section)
            }
            self.deletePendingData(indexPath: indexPath, from: "accept")
            self.progressTableView.reloadData()
        }
    }
    
    func addProgressData(pendingData: PendingBookPlaceDetail) {
        
        let mainData = ["course_id": pendingData.course_id,
                        "place_id": pendingData.place_id,
                        "transaction_to_admin": "-1"]
        
        var subData: [String: Any] = [:]
        
        for i in 1...Int((self.courseObj[pendingData.course_id]?.timeOfCourse)!)! {
            
            if i == 1 {
                
                let timeSchedule = ["start_train_date": pendingData.start_train_date,
                                       "start_train_time": pendingData.start_train_time,
                                       "status": "1",
                                       "transaction_to_trainer": "-1"]
                subData["\(i)"] = timeSchedule
            } else {
                
                let timeSchedule = ["start_train_date": "-1",
                                    "start_train_time": "-1",
                                    "status": "-1",
                                    "transaction_to_trainer": "-1"]
                subData["\(i)"] = timeSchedule
            }
        }
        
        print(subData)
        self.ref.child("progress_schedule_detail").child(pendingData.trainer_id).child(pendingData.trainee_id).child(pendingData.schedule_key).updateChildValues(mainData) { (err, progressRef) in
            if let err = err {
                print(err.localizedDescription)
                self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                return
            }
            progressRef.updateChildValues(subData, withCompletionBlock: { (err1, subRef) in
                if let err1 = err1 {
                    print(err1.localizedDescription)
                    self.createAlert(alertTitle: err1.localizedDescription, alertMessage: "")
                    return
                }
            })
        }
    }
    
    func deleteSchedulePlaceBook(pendingData: PendingBookPlaceDetail) {
        print(pendingData.schedule_key)
        self.ref.child("schedule_place_books").child(pendingData.place_id).child(pendingData.trainer_id).child(pendingData.schedule_key).removeValue { (err, scheduleRef) in
            if let err = err {
                print(err.localizedDescription)
                self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                return
            }
        }
    }
    
    func deletePendingData(indexPath: IndexPath, from: String) {
        
        if from == "decline" {
            
            let pendingData = self.pendingDataListsMatch[indexPath.section].pendingDetail[indexPath.row]
            
            self.ref.child("pending_schedule_detail").child(pendingData.trainer_id).child(pendingData.schedule_key).child(pendingData.trainee_id).removeValue { (err, pendingRef) in
            
                self.view.removeBluerLoader()
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                self.tabBarController?.tabBar.isHidden = false
            
                if let err = err {
                    print(err.localizedDescription)
                    self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                    return
                }
    
                self.pendingDataListsMatch[indexPath.section].pendingDetail.remove(at: indexPath.row)
                if self.pendingDataListsMatch[indexPath.section].pendingDetail.count == 0 {
                    self.pendingDataListsMatch.remove(at: indexPath.section)
                }
                self.progressTableView.reloadData()
            }
        } else if from == "accept" {
            
            for (index, eachPendingDetail) in self.pendingDataListsMatch[indexPath.section].pendingDetail.enumerated() {
                self.ref.child("pending_schedule_detail").child(eachPendingDetail.trainer_id).child(eachPendingDetail.schedule_key).child(eachPendingDetail.trainee_id).removeValue(completionBlock: { (err, ref) in

                    self.view.removeBluerLoader()
                    self.navigationController?.setNavigationBarHidden(false, animated: true)
                    self.tabBarController?.tabBar.isHidden = false

                    if let err = err {
                        print(err.localizedDescription)
                        self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                        return
                    }

                    if index == self.pendingDataListsMatch[indexPath.section].pendingDetail.count-1 {
                        self.pendingDataListsMatch.remove(at: indexPath.section)
                        self.progressTableView.reloadData()
                    }

                })
                print("###\(index): \(eachPendingDetail.getData())")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch self.statusSegmented.selectedSegmentIndex {
        case 0:
            return self.pendingDataListsMatch[section].date
        case 1:
            return ""
        default:
            return ""
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        switch self.statusSegmented.selectedSegmentIndex {
        case 0:
            let headerBtn = UIButton(type: .system)
            headerBtn.setTitle("Close", for: .normal)
            headerBtn.setTitleColor(.black, for: .normal)
            headerBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            headerBtn.addTarget(self, action: #selector(self.handleExpandCollapse(headerBtn:)), for: .touchUpInside)
            headerBtn.tag = section
            headerBtn.translatesAutoresizingMaskIntoConstraints = false
            
            let label = UILabel()
            label.text = self.pendingDataListsMatch[section].date
            label.font = UIFont.boldSystemFont(ofSize: 14.0)
            label.numberOfLines = 1
            label.translatesAutoresizingMaskIntoConstraints = false
            
            let view = UIView()
            view.backgroundColor = UIColor.clear
            view.addSubview(label)
            view.addSubview(headerBtn)
            
            let views = ["label": label, "button": headerBtn, "view": view]
            
            let horizontalLayoutContraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[label(<=250)]-0-[button]-|", options: .alignAllCenterY, metrics: nil, views: views)
            view.addConstraints(horizontalLayoutContraints)
            
            let verticalLayoutContraint = NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
            view.addConstraint(verticalLayoutContraint)
            
            return view
        case 1:
            let label = UILabel()
            label.text = "\(self.paymentDataListsMatch[section].start_train_date) \(self.paymentDataListsMatch[section].start_train_time)"
            label.font = UIFont.boldSystemFont(ofSize: 14.0)
            label.numberOfLines = 1
            label.translatesAutoresizingMaskIntoConstraints = false
            
            let view = UIView()
            view.backgroundColor = UIColor.clear
            view.addSubview(label)
            
            let views = ["label": label, "view": view]
            
            let horizontalLayoutConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[label(<=250)]-|", options: .alignAllCenterY, metrics: nil, views: views)
            view.addConstraints(horizontalLayoutConstraints)
            
            let verticalLayoutConstraint = NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
            view.addConstraint(verticalLayoutConstraint)
            
            return view
        default:
            return UIView()
        }
    }

    @objc func handleExpandCollapse(headerBtn: UIButton) {

        print("handle")
        print(headerBtn.tag)

        let section = headerBtn.tag

        var indexPaths = [IndexPath]()
        for row in self.pendingDataListsMatch[section].pendingDetail.indices {
            let indexPath = IndexPath(row: row, section: section)
            indexPaths.append(indexPath)
        }

        let isExpanded = self.pendingDataListsMatch[section].isExpanded
        self.pendingDataListsMatch[section].isExpanded = !isExpanded
        
        headerBtn.setTitle(isExpanded ? "Open" : "Close", for: .normal)
        
        if isExpanded {
            self.progressTableView.deleteRows(at: indexPaths, with: .fade)
        } else {
            self.progressTableView.insertRows(at: indexPaths, with: .fade)
        }
        
        print("indexPaths: \(indexPaths)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func pendingSegmentedControlAction(_ sender: CustomSegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            // Confirmation
            self.progressTableView.reloadData()
        }
        if sender.selectedSegmentIndex == 1 {
            // Payment
            self.progressTableView.reloadData()
        }
        if sender.selectedSegmentIndex == 2 {
            // Ongoing
            self.progressTableView.reloadData()
        }
        if sender.selectedSegmentIndex == 3 {
            // Successful
            self.progressTableView.reloadData()
        }
    }
}
