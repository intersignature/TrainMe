//
//  EachOngoingTrainerViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 19/12/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class EachOngoingTrainerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
   
    @IBOutlet weak var eachOngoingTrainerTableView: UITableView!
    
    var selectedOngoing: OngoingDetail!
    var ref: DatabaseReference!
    var currentUser: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("selectedOngoingzz: \(selectedOngoing)")
        
        self.ref = Database.database().reference()
        self.currentUser = Auth.auth().currentUser
        
        self.eachOngoingTrainerTableView.delegate = self
        self.eachOngoingTrainerTableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.selectedOngoing.eachOngoingDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "EachOngoingTrainerTableViewCell") as! EachOngoingTrainerTableViewCell
        cell.countLb.text = self.selectedOngoing.eachOngoingDetails[indexPath.row].count
        cell.dateAndTimeScheduleLb.text = "\(self.selectedOngoing.eachOngoingDetails[indexPath.row].start_train_date) \(self.selectedOngoing.eachOngoingDetails[indexPath.row].start_train_time)"
        cell.changeScheduleBtn.tag = indexPath.row
        cell.changeScheduleBtn.addTarget(self, action: #selector(self.changeSchedule(sender:)), for: .touchUpInside)
        cell.confirmSuccessTrainBtn.tag = indexPath.row
        cell.confirmSuccessTrainBtn.addTarget(self, action: #selector(self.confirmBtnAction(sender:)), for: .touchUpInside)
        
        if self.selectedOngoing.eachOngoingDetails[indexPath.row].status == "-1" {
            cell.changeScheduleBtn.isEnabled = false
            cell.confirmSuccessTrainBtn.isEnabled = false
            cell.statusLb.text = "Pending"
        } else if self.selectedOngoing.eachOngoingDetails[indexPath.row].status == "1" {
            cell.changeScheduleBtn.isEnabled = true
            cell.confirmSuccessTrainBtn.isEnabled = true
            if self.selectedOngoing.eachOngoingDetails[indexPath.row].is_trainer_confirm == "1" && self.selectedOngoing.eachOngoingDetails[indexPath.row].is_trainee_confirm == "-1" {
                cell.changeScheduleBtn.isEnabled = false
                cell.confirmSuccessTrainBtn.isEnabled = false
            } else if self.selectedOngoing.eachOngoingDetails[indexPath.row].is_trainer_confirm == "-1" && self.selectedOngoing.eachOngoingDetails[indexPath.row].is_trainee_confirm == "1" {
                cell.changeScheduleBtn.isEnabled = false
            }
            cell.statusLb.text = "Ongoing"
        } else if self.selectedOngoing.eachOngoingDetails[indexPath.row].status == "2" {
            cell.changeScheduleBtn.isEnabled = false
            cell.confirmSuccessTrainBtn.isEnabled = false
            cell.statusLb.text = "Successful"
        } else if self.selectedOngoing.eachOngoingDetails[indexPath.row].status == "3" {
            cell.changeScheduleBtn.isEnabled = true
            cell.confirmSuccessTrainBtn.isEnabled = false
            cell.statusLb.text = "Change schedule requested"
        }
        return cell
    }
    
    @objc func changeSchedule(sender: UIButton) {
        
        //TODO: changeSchedule
        print("changeSchedule: \(sender.tag)")
    }
    
    @objc func confirmBtnAction(sender: UIButton) {
        
        let alert = UIAlertController(title: "Are you sure to confirm training?", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
//            self.confirmSuccessStatusToDatabase(sender: sender)
            self.checkTraineeIsConfirm(sender: sender)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func checkTraineeIsConfirm(sender: UIButton) {
        
        self.ref.child("progress_schedule_detail").child(self.currentUser.uid).child(self.selectedOngoing.traineeId).child(self.selectedOngoing.ongoingId).child(self.selectedOngoing.eachOngoingDetails[sender.tag].count).child("is_trainee_confirm").observeSingleEvent(of: .value) { (snapshot) in
            let isTraineeConfirm = snapshot.value as! String
            self.confirmSuccessStatusToDatabase(isTraineeConfirm: isTraineeConfirm, sender: sender)
        }
    }
    
    func confirmSuccessStatusToDatabase(isTraineeConfirm: String, sender: UIButton) {
        
        var confirmData = ["is_trainer_confirm": "1"]
        
        if isTraineeConfirm == "1" {
            confirmData = ["is_trainer_confirm": "1",
                           "status": "2"]
        }
        
        self.ref.child("progress_schedule_detail").child(self.currentUser.uid).child(self.selectedOngoing.traineeId).child(self.selectedOngoing.ongoingId).child(self.selectedOngoing.eachOngoingDetails[sender.tag].count).updateChildValues(confirmData) { (err, ref) in
            
            if let err = err {
                print(err.localizedDescription)
                self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                return
            }
            
            self.selectedOngoing.eachOngoingDetails[sender.tag].is_trainer_confirm = "1"
            if isTraineeConfirm == "1" {
                self.selectedOngoing.eachOngoingDetails[sender.tag].status = "2"
                if self.selectedOngoing.eachOngoingDetails.count > Int(self.selectedOngoing.eachOngoingDetails[sender.tag].count)! {
                    self.setStatusToNextSchedule(sender: sender)
                } else {
                    //TODO: Transfer money to trainer
                    self.createAlert(alertTitle: "This course is finish!", alertMessage: "")
                    self.eachOngoingTrainerTableView.reloadData()
                }
            } else {
                self.eachOngoingTrainerTableView.reloadData()
                self.createAlert(alertTitle: "Confirm training successfully", alertMessage: "")
            }
        }
        print("confirmSuccessStatusToDatabase: \(sender.tag)")
    }
    
    func setStatusToNextSchedule(sender: UIButton) {
        
        let statusNextScheduleData = ["status": "1"]
        self.ref.child("progress_schedule_detail").child(self.currentUser.uid).child(self.selectedOngoing.traineeId).child(self.selectedOngoing.ongoingId).child(self.selectedOngoing.eachOngoingDetails[Int(sender.tag)+1].count).updateChildValues(statusNextScheduleData) { (err, ref) in
            
            if let err = err {
                self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                print(err.localizedDescription)
                return
            }
            self.selectedOngoing.eachOngoingDetails[Int(sender.tag)+1].status = "1"
            self.eachOngoingTrainerTableView.reloadData()
            self.createAlert(alertTitle: "Confirm training successfully", alertMessage: "")
        }
    }
    
}
