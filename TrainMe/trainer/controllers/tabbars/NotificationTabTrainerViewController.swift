//
//  NotificationTabTrainerViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 26/8/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import SWRevealViewController
import FirebaseDatabase
import FirebaseAuth

class NotificationTabTrainerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var menuBtn: UIBarButtonItem!
    @IBOutlet weak var notificationTableView: UITableView!
    
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

        self.ref = Database.database().reference()
        self.currentUser = Auth.auth().currentUser
        
        initSideMenu()
        self.notificationTableView.delegate = self
        self.notificationTableView.dataSource = self
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
                                                timeStamp: notificationVal["timestamp"] as! String,
                                                isReport: notificationVal["is_report"] as! String)
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
            self.notificationTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notificationArrSort.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTrainerTableCell") as! NotificationTrainerTableViewCell
        cell.isReadView.isHidden = notificationArrSort[indexPath.row].isRead == "1" ? true : false
        cell.profileImg.downloaded(from: (self.userProfileObj[self.notificationArrSort[indexPath.row].fromUid]?.profileImageUrl)!)
        cell.nameLb.text = self.userProfileObj[self.notificationArrSort[indexPath.row].fromUid]?.fullName
        cell.timeAgoLb.text = Date().getDiffToCurentTime(from: self.notificationArrSort[indexPath.row].timeStamp)
        cell.descriptionLb.text = self.notificationArrSort[indexPath.row].description
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.notificationTableView.tableFooterView = UIView()
        
        self.title = "notification".localized()
        
        setupNavigationStyle()
        self.getNotificationData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
