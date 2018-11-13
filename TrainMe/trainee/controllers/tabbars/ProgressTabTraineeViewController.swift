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
    @IBOutlet weak var statusSegmented: CustomSegmentedControl!
    
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
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.pendingDatas.removeAll()
        self.pendingDataSorted.removeAll()
        self.timeListPending.removeAll()
        self.timeListSortedPending.removeAll()
        self.trainerId.removeAll()
        self.trainerObj.removeAll()
        self.courseId.removeAll()
        self.courseName.removeAll()
        self.placeId.removeAll()
        self.placeName.removeAll()
        
        self.getPendingObj()
    }
    
    func getPendingObj() {
        
        self.ref.child("pending_schedule_detail").observeSingleEvent(of: .value, with: { (snapshot) in
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
            self.courseName[courseId] = (value["course_name"] as! String)
            
            if self.trainerId.count == self.trainerObj.count && self.trainerId.count != 0 &&
                self.courseId.count == self.courseName.count && self.courseId.count != 0 &&
                self.placeId.count == self.placeName.count && self.placeId.count != 0 {
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
            
            self.placeName[placeId] = place.name
            
            if self.trainerId.count == self.trainerObj.count && self.trainerId.count != 0 &&
                self.courseId.count == self.courseName.count && self.courseId.count != 0 &&
                self.placeId.count == self.placeName.count && self.placeId.count != 0 {
                self.sortDate()
            }
        }
    }
    
    func sortDate() {
        
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
                               courseName: self.courseName[self.pendingDataSorted[indexPath.section].pendingDetail[indexPath.row].course_id]!,
                               placeName: self.placeName[self.pendingDataSorted[indexPath.section].pendingDetail[indexPath.row].place_id]!,
                               position: "\(indexPath.section)-\(indexPath.row)")
            
            cell.cancelBtn.addTarget(self, action: #selector(self.cancelBtnAction(cancelBtn:)), for: .touchUpInside)
            cell.cancelBtn.setTitleColor(UIColor.red, for: .normal)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TraineePaymentTableViewCell") as! PaymentTableViewCell
            
            cell.setDataToCell(trainerProfileUrl: (self.trainerObj[self.paymentDataSorted[indexPath.row].trainer_id]?.profileImageUrl)!,
                               name: (self.trainerObj[self.paymentDataSorted[indexPath.row].trainer_id]?.fullName)!,
                               courseName: self.courseName[self.paymentDataSorted[indexPath.row].course_id]!,
                               placeName: self.placeName[self.paymentDataSorted[indexPath.row].place_id]!,
                               time: "\(self.paymentDataSorted[indexPath.row].start_train_date) \(self.paymentDataSorted[indexPath.row].start_train_time)",
                               position: "\(indexPath.section)-\(indexPath.row)")
            
            cell.buyBtn.addTarget(self, action: #selector(self.paymentAction(buyBtn:)), for: .touchUpInside)
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    @objc func cancelBtnAction(cancelBtn: UIButton) {
        
        let cencelIndexPath = IndexPath(row: Int(cancelBtn.accessibilityLabel!.components(separatedBy: "-")[1])!, section: Int(cancelBtn.accessibilityLabel!.components(separatedBy: "-")[0])!)
        
        let alert = UIAlertController(title: "Cancel?", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            self.view.showBlurLoader()
            self.tabBarController?.tabBar.isHidden = true
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            
            self.deletePendingData(deletePendingIndexPath: cencelIndexPath)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func paymentAction(buyBtn: UIButton) {
        
        //TODO: Payment with Omise
        
        let payIndexPath = IndexPath(row: Int((buyBtn.accessibilityLabel?.components(separatedBy: "-")[1])!)!, section: Int((buyBtn.accessibilityLabel?.components(separatedBy: "-")[0])!)!)
        
        print("pay at: \(payIndexPath.section) \(payIndexPath.row)")
    }

    func deletePendingData(deletePendingIndexPath: IndexPath) {
        
        let deletePendingData = self.pendingDataSorted[deletePendingIndexPath.section].pendingDetail[deletePendingIndexPath.row]
        self.ref.child("pending_schedule_detail").child(deletePendingData.trainer_id).child(deletePendingData.schedule_key).child(self.currentUser.uid).removeValue { (err, ref) in
            
            self.view.removeBluerLoader()
            self.tabBarController?.tabBar.isHidden = false
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            
            if let err = err {
                print(err.localizedDescription)
                self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                return
            }
            
            self.pendingDataSorted[deletePendingIndexPath.section].pendingDetail.remove(at: deletePendingIndexPath.row)
            if self.pendingDataSorted[deletePendingIndexPath.section].pendingDetail.count == 0 {
                self.pendingDataSorted.remove(at: deletePendingIndexPath.section)
            }
            self.pendingTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch self.statusSegmented.selectedSegmentIndex {
        case 0:
            return self.pendingDataSorted[section].date
        case 1:
            return "Please select your course to pay"
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
        default:
            return 0
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
            label.text = "Please select your course to pay"
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
        
        headerBtn.setTitle(isExpanded ? "Open" : "Close", for: .normal)
        
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
    
    @IBAction func progressCustomSegmentedControl(_ sender: CustomSegmentedControl) {
        
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
}
