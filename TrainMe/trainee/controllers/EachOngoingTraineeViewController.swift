//
//  EachOngoingTraineeViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 8/12/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class EachOngoingTraineeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var eachOngoingScheduleTableView: UITableView!
    
    var selectedOngoing: OngoingDetail!
    
    var selectedTrainerUid: String!
    var selectedTraineeUid: String!
    var selectedOngoingId: String!
    
    var currentUser: User!
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("EachOngoingTraineeViewController \(self.selectedOngoing)")
        
        self.ref = Database.database().reference()
        self.currentUser = Auth.auth().currentUser
        
        self.getEachOngoing()
        
        self.eachOngoingScheduleTableView.dataSource = self
        self.eachOngoingScheduleTableView.delegate = self
    }
    
    func getEachOngoing() {
        
        self.ref.child("progress_schedule_detail").child(self.selectedTrainerUid).child(self.selectedTraineeUid).child(self.selectedOngoingId).observe(.value, with: { (snapshot) in
            let value = snapshot.value as? AnyObject
            print(value!.count)
            var tempEachOngoings: [EachOngoingDetail] = []
            for i in 1...(Int(value!.count)-4){
                print("courseId: \(i)")
                let eachDetailValue = value![String(i)] as? NSDictionary
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
            
            var tempOngoingDetail = OngoingDetail(ongoingId: self.selectedOngoingId,
                                                  trainerId: self.selectedTrainerUid,
                                                  courseId: value!["course_id"] as! String,
                                                  placeId: value!["place_id"] as! String,
                                                  transactionToAdmin: value!["transaction_to_admin"] as! String,
                                                  transactionToTrainer: value!["transaction_to_trainer"] as! String,
                                                  eachOngoingDetails: tempEachOngoings)
            tempOngoingDetail.traineeId = self.currentUser.uid
            self.selectedOngoing = tempOngoingDetail
            self.eachOngoingScheduleTableView.reloadData()
        }) { (err) in
            self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
            print(err.localizedDescription)
            return
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.selectedOngoing.eachOngoingDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EachOngoingTableViewCell") as! EachOngoingTraineeTableViewCell
        cell.selectedOngoing = self.selectedOngoing.eachOngoingDetails[indexPath.row]
        cell.changeScheduleBtn.setTitle("change_schedule".localized(), for: .normal)
        cell.changeScheduleBtn.tag = indexPath.row
        cell.reviewBtn.setTitle("review".localized(), for: .normal)
        cell.reviewBtn.tag = indexPath.row
        cell.changeScheduleBtn.addTarget(self, action: #selector(self.requestScheduleBtnAction(sender:)), for: .touchUpInside)
        cell.reviewBtn.addTarget(self, action: #selector(self.reviewBtnAction(sender:)), for: .touchUpInside)
        cell.setDataToCell()
        
        if self.selectedOngoing.eachOngoingDetails[indexPath.row].status == "-1" {
            cell.changeScheduleBtn.isEnabled = false
            cell.reviewBtn.isEnabled = false
            cell.statusLb.text = "pending".localized()
        } else if self.selectedOngoing.eachOngoingDetails[indexPath.row].status == "1" {
            cell.changeScheduleBtn.isEnabled = true
            cell.reviewBtn.isEnabled = true
 
            if self.selectedOngoing.eachOngoingDetails[indexPath.row].is_trainer_confirm == "1" && self.selectedOngoing.eachOngoingDetails[indexPath.row].is_trainee_confirm == "-1"{
                cell.changeScheduleBtn.isEnabled = false
            } else if self.selectedOngoing.eachOngoingDetails[indexPath.row].is_trainer_confirm == "-1" &&
                self.selectedOngoing.eachOngoingDetails[indexPath.row].is_trainee_confirm == "1"{
                cell.changeScheduleBtn.isEnabled = false
                cell.reviewBtn.isEnabled = false
            }
            cell.statusLb.text = "ongoing".localized()
        } else if self.selectedOngoing.eachOngoingDetails[indexPath.row].status == "2" {
            cell.changeScheduleBtn.isEnabled = false
            cell.reviewBtn.isEnabled = false
            cell.statusLb.text = "successful".localized()
        } else if self.selectedOngoing.eachOngoingDetails[indexPath.row].status == "3" {
            cell.changeScheduleBtn.isEnabled = false
            cell.reviewBtn.isEnabled = false
            cell.statusLb.text = "change_schedule_requested".localized()
        }
        return cell
    }
    
    @objc func requestScheduleBtnAction(sender: UIButton) {
        
        let alert = UIAlertController(title: "confirm_to_request_change_schedule".localized(), message: "\("from".localized()) \(self.selectedOngoing.eachOngoingDetails[sender.tag].start_train_date) \(self.selectedOngoing.eachOngoingDetails[sender.tag].start_train_time)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "confirm".localized(), style: .default, handler: { (action) in
            
            print("Confirm to request")
            self.view.showBlurLoader()
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            self.changeStatusToRequestChangeSchedule(changeIndex: sender.tag)
        }))
        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func changeStatusToRequestChangeSchedule(changeIndex: Int) {
        
        let changeData = ["status": "3"]
        self.ref.child("progress_schedule_detail").child(self.selectedOngoing.trainerId).child(self.currentUser.uid).child(self.selectedOngoing.ongoingId).child(self.selectedOngoing.eachOngoingDetails[changeIndex].count).updateChildValues(changeData) { (err, ref) in
            
            if let err = err {
                self.view.removeBluerLoader()
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                print(err.localizedDescription)
                self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                return
            }
            
            self.addNotificationDatabase(toUid: self.selectedOngoing.trainerId, description: "Your traineer want to change schedule from \(self.selectedOngoing.eachOngoingDetails[changeIndex].start_train_date) \(self.selectedOngoing.eachOngoingDetails[changeIndex].start_train_time)")
            self.selectedOngoing.eachOngoingDetails[changeIndex].status = "3"
            self.eachOngoingScheduleTableView.reloadData()
            
        }
        
    }
    
    @objc func reviewBtnAction(sender: UIButton) {
        
        self.parent?.performSegue(withIdentifier: "EachOngoingProgressToReview", sender: sender.tag)
    }
    
    func addNotificationDatabase(toUid: String, description: String) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        dateFormatter.locale = Locale(identifier: "en")
        let currentStringOfDate = dateFormatter.string(from: Date())
        
        let notificationData = ["from_uid": self.currentUser.uid,
                                "description": description,
                                "timestamp": currentStringOfDate,
                                "is_read": "0",
                                "is_report": "0"]
        
        self.ref.child("notifications").child(toUid).childByAutoId().updateChildValues(notificationData) { (err, ref) in
            if let err = err {
                self.view.removeBluerLoader()
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                print(err.localizedDescription)
                return
            }
            self.view.removeBluerLoader()
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.createAlert(alertTitle: "request_change_schedule_successful".localized(), alertMessage: "")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.eachOngoingScheduleTableView.tableFooterView = UIView()
    }
}
