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
    
    var uid: [String] = []
    var userProfileObj: [String: UserProfile] = [:]
    
    var ref: DatabaseReference!
    var currentUser: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.ref = Database.database().reference()
        self.currentUser = Auth.auth().currentUser
        
        initSideMenu()
        self.title = NSLocalizedString("notification", comment: "")
        self.notificationTableView.delegate = self
        self.notificationTableView.dataSource = self
    }

    func getNotificationData() {
        
        let notificationRef = ref.child("notifications").child(self.currentUser.uid)
        notificationRef.observe(.value, with: { (snapshot) in
            
            self.notificationArr.removeAll()
            let values = snapshot.value as! [String: NSDictionary]
            values.forEach({ (notificationKey, notificationVal) in
                

                if self.userProfileObj[notificationVal["from_uid"] as! String] == nil && !self.uid.contains(notificationVal["from_uid"] as! String) {
                    self.uid.append(notificationVal["from_uid"] as! String)
                    self.getProfileObj(uid: notificationVal["from_uid"] as! String)
                }
                
                let notification = Notification(toUid: self.currentUser.uid,
                                                fromUid: notificationVal["from_uid"] as! String,
                                                description: notificationVal["description"] as! String,
                                                isRead: notificationVal["is_read"] as! String,
                                                timeStamp: notificationVal["timestamp"] as! String)
                self.notificationArr.append(notification)
                
                self.uid.forEach({ (eachUid) in
                    if self.userProfileObj[eachUid] == nil {
                        return
                    }
                    self.notificationTableView.reloadData()
                })
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
                                         omiseCusId: (value["omise_cus_id"] as! String))
            self.userProfileObj[uid] = profileObj
            
            if self.userProfileObj.count == self.uid.count {
                self.notificationTableView.reloadData()
            }
            
        }) { (err) in
            print(err.localizedDescription)
            self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
            return
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notificationArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTrainerTableCell") as! NotificationTrainerTableViewCell
        cell.isReadView.isHidden = notificationArr[indexPath.row].isRead == "1" ? true : false
        cell.profileImg.downloaded(from: (self.userProfileObj[self.notificationArr[indexPath.row].fromUid]?.profileImageUrl)!)
        cell.nameLb.text = self.userProfileObj[self.notificationArr[indexPath.row].fromUid]?.fullName
        cell.timeAgoLb.text = Date().getDiffToCurentTime(from: self.notificationArr[indexPath.row].timeStamp)
        cell.descriptionLb.text = self.notificationArr[indexPath.row].description
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
        
        setupNavigationStyle()
        self.getNotificationData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
