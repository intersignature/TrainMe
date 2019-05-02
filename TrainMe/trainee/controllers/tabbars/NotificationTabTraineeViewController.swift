//
//  NotificationTabTraineeViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 15/9/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import SWRevealViewController
import FirebaseDatabase
import FirebaseAuth

class NotificationTabTraineeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var menuBtn: UIBarButtonItem!
    @IBOutlet weak var notificationTraineeTableView: UITableView!
    
    var notificationArr: [Notification] = []
    var notificationArrSort: [Notification] = []
    
    var uid: [String] = []
    var userProfileObj: [String: UserProfile] = [:]
    
    var timeList: [String] = []
    var timeListSorted: [Date] = []
    
    var ref: DatabaseReference!
    var currentUser: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initSideMenu()
        
        self.ref = Database.database().reference()
        self.currentUser = Auth.auth().currentUser
        
        initSideMenu()
        self.notificationTraineeTableView.delegate = self
        self.notificationTraineeTableView.dataSource = self
    }
    
    func getNotificationData() {
        
        let notificationRef = ref.child("notifications").child(self.currentUser.uid)
        notificationRef.observe(.value, with: { (snapshot) in
            
            self.notificationArr.removeAll()
            self.notificationArrSort.removeAll()
            self.timeList.removeAll()
            self.timeListSorted.removeAll()
            guard let values = snapshot.value as? [String: NSDictionary] else { return }
            values.forEach({ (notificationKey, notificationVal) in
                
                if !self.timeList.contains(notificationVal["timestamp"] as! String) {
                    self.timeList.append(notificationVal["timestamp"] as! String)
                }
                
                if self.userProfileObj[notificationVal["from_uid"] as! String] == nil && !self.uid.contains(notificationVal["from_uid"] as! String) {
                    self.uid.append(notificationVal["from_uid"] as! String)
                    self.getProfileObj(uid: notificationVal["from_uid"] as! String)
                }
                
                let notification = Notification(id: notificationKey,
                                                toUid: self.currentUser.uid,
                                                fromUid: notificationVal["from_uid"] as! String,
                                                description: notificationVal["description"] as! String,
                                                isRead: notificationVal["is_read"] as! String,
                                                timeStamp: notificationVal["timestamp"] as! String)
                
                if notification.canReport == "1" { self.getReport(notificationCanReport: notification) }
                self.notificationArr.append(notification)
            })
            
            self.uid.forEach({ (eachUid) in
                if self.userProfileObj[eachUid] == nil {
                    return
                }
                self.sortDate()
            })
        }) { (err) in
            print(err.localizedDescription)
            self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
            return
        }
    }
    
    func getReport(notificationCanReport noti: Notification) {
        
        
    }
    
    func getProfileObj(uid: String) {
        
        self.ref.child("user").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let value = snapshot.value as! NSDictionary
            let profileObj = UserProfile(fullName: (value["name"] as! String),
                                         email: (value["email"] as! String),
                                         dateOfBirth: (value["dateOfBirth"] as! String),
                                         weight: (value["weight"] as! String),
                                         height: (value["height"] as! String),
                                         gender: (value["gender"] as! String),
                                         role: (value["role"] as! String),
                                         profileImageUrl: (value["profileImageUrl"] as! String),
                                         uid: uid,
                                         omiseCusId: (value["omise_cus_id"] as! String),
                                         ban: (value["ban"] as! Bool))
            self.userProfileObj[uid] = profileObj
            self.uid.forEach({ (eachUid) in
                if self.userProfileObj[eachUid] == nil {
                    return
                }
                self.sortDate()
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
        
        self.timeListSorted = convertedArray.sorted(by: { $0.compare($1) == .orderedDescending })
        self.matchSortedDate(dateFormatter: dateFormatter)
    }
    
    func matchSortedDate(dateFormatter: DateFormatter) {
        
        self.timeListSorted.forEach { (date) in
            let dateString = dateFormatter.string(from: date)
            self.notificationArr.forEach({ (eachNotification) in
                if dateString == eachNotification.timeStamp {
                    self.notificationArrSort.append(eachNotification)
                }
            })
        }
        print(self.notificationArrSort)
        if self.userProfileObj.count == self.uid.count {
            self.notificationTraineeTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notificationArrSort.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(notificationArrSort[indexPath.row].getData())
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTraineeTableCell") as! NotificationTraineeTableViewCell
        cell.isReadView.isHidden = notificationArrSort[indexPath.row].isRead == "1" ? true : false
        cell.profileImg.downloaded(from: (self.userProfileObj[self.notificationArrSort[indexPath.row].fromUid]?.profileImageUrl)!)
        cell.nameLb.text = self.userProfileObj[self.notificationArrSort[indexPath.row].fromUid]?.fullName
        cell.timeAgoLb.text = Date().getDiffToCurentTime(from: self.notificationArrSort[indexPath.row].timeStamp)
        cell.descriptionLb.text = self.notificationArrSort[indexPath.row].description
        cell.reportBtn.accessibilityLabel = "\(notificationArrSort[indexPath.row].id) \(notificationArrSort[indexPath.row].fromUid) \(notificationArrSort[indexPath.row].toUid)" // NotificationId, trainerId, traineeId
        cell.reportBtn.addTarget(self, action: #selector(reportButtonAction(reportBtn:)), for: .touchUpInside)
        if notificationArrSort[indexPath.row].canReport == "0" {
            cell.reportBtn.isHidden = true
        }
        return cell
    }
    
    @objc func reportButtonAction(reportBtn: UIButton) {
        
        print(reportBtn.accessibilityLabel! as String)
        let reportInfo = reportBtn.accessibilityLabel?.components(separatedBy: " ")
        
        let reportAlert = UIAlertController(title: "Report trainer decline", message: "", preferredStyle: .alert)
        reportAlert.addTextField { (reportTf) in
            reportTf.placeholder = "Report trainer"
        }
        reportAlert.addAction(UIAlertAction(title: "confirm".localized(), style: .default, handler: { (action) in
            print(reportAlert.textFields![0].text! as String)
            if reportAlert.textFields![0].text! == "" {
                self.createAlert(alertTitle: "please_fill_in_the_blank".localized(), alertMessage: "")
            } else {
                self.addReportTrainer(notificationId: reportInfo![0], trainerId: reportInfo![1], traineeId: reportInfo![2], reportMessage: reportAlert.textFields![0].text!)
            }
        }))
        reportAlert.addAction(UIAlertAction(title: "cancel".localized(), style: .destructive, handler: nil))
            
        present(reportAlert, animated: true, completion: nil)
    }
    
    func addReportTrainer(notificationId notiId: String, trainerId: String, traineeId: String, reportMessage: String) {
        
        let reportData = ["report_message": reportMessage, "notification_id": notiId]
        self.ref.child("report_from_decline").child(trainerId).child(traineeId).updateChildValues(reportData) { (err, ref) in
            if let err = err {
                self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                return
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "notification".localized()
        
        self.notificationTraineeTableView.tableFooterView = UIView()
        
        setupNavigationStyle()
        self.getNotificationData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
}
