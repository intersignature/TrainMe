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
            self.confirmSuccessStatusToDatabase(sender: sender)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func confirmSuccessStatusToDatabase(sender: UIButton) {
        
        let confirmData = ["is_trainer_confirm": "1"]
        
        self.ref.child("progress_schedule_detail").child(self.currentUser.uid).child(self.selectedOngoing.traineeId).child(self.selectedOngoing.ongoingId).child(self.selectedOngoing.eachOngoingDetails[sender.tag].count).updateChildValues(confirmData) { (err, ref) in
            
            if let err = err {
                print(err.localizedDescription)
                self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                return
            }
            
            //TODO: Change data to model and reload table
            self.createAlert(alertTitle: "Confirm training successfully", alertMessage: "")
        }
        print("confirmSuccessStatusToDatabase: \(sender.tag)")
    }
    
}
