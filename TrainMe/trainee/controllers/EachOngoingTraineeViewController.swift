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
    var currentUser: User!
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("EachOngoingTraineeViewController \(self.selectedOngoing)")
        
        self.ref = Database.database().reference()
        self.currentUser = Auth.auth().currentUser
        
        self.eachOngoingScheduleTableView.dataSource = self
        self.eachOngoingScheduleTableView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.selectedOngoing.eachOngoingDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EachOngoingTableViewCell") as! EachOngoingTraineeTableViewCell
        cell.selectedOngoing = self.selectedOngoing.eachOngoingDetails[indexPath.row]
        cell.changeScheduleBtn.tag = indexPath.row
        cell.reviewBtn.tag = indexPath.row
        cell.changeScheduleBtn.addTarget(self, action: #selector(self.requestScheduleBtnAction(sender:)), for: .touchUpInside)
        cell.reviewBtn.addTarget(self, action: #selector(self.reviewBtnAction(sender:)), for: .touchUpInside)
        cell.setDataToCell()
        
        if self.selectedOngoing.eachOngoingDetails[indexPath.row].status == "-1" {
            cell.changeScheduleBtn.isEnabled = false
            cell.reviewBtn.isEnabled = false
            cell.statusLb.text = "Pending"
        } else if self.selectedOngoing.eachOngoingDetails[indexPath.row].status == "1" {
            cell.changeScheduleBtn.isEnabled = true
            cell.reviewBtn.isEnabled = true
            if self.selectedOngoing.eachOngoingDetails[indexPath.row].is_trainer_confirm == "1" {
                cell.changeScheduleBtn.isEnabled = false
            }
            cell.statusLb.text = "Ongoing"
        } else if self.selectedOngoing.eachOngoingDetails[indexPath.row].status == "2" {
            cell.changeScheduleBtn.isEnabled = false
            cell.reviewBtn.isEnabled = false
            cell.statusLb.text = "Successful"
        } else if self.selectedOngoing.eachOngoingDetails[indexPath.row].status == "3" {
            cell.changeScheduleBtn.isEnabled = true
            cell.reviewBtn.isEnabled = true
            cell.statusLb.text = "Change schedule requested"
        }
        return cell
    }
    
    @objc func requestScheduleBtnAction(sender: UIButton) {
        
        let alert = UIAlertController(title: "Confirm to request change schedule?", message: "from \(self.selectedOngoing.eachOngoingDetails[sender.tag].start_train_date) \(self.selectedOngoing.eachOngoingDetails[sender.tag].start_train_time)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            print("Confirm to request")
            //TODO: request
            self.changeStatusToRequestChangeSchedule(changeIndex: sender.tag)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func changeStatusToRequestChangeSchedule(changeIndex: Int) {
        
        let changeData = ["status": "3"]
        self.ref.child("progress_schedule_detail").child(self.selectedOngoing.trainerId).child(self.currentUser.uid).child(self.selectedOngoing.ongoingId).child(self.selectedOngoing.eachOngoingDetails[changeIndex].count).updateChildValues(changeData) { (err, ref) in
            
            if let err = err {
                print(err.localizedDescription)
                self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                return
            }
            
            self.selectedOngoing.eachOngoingDetails[changeIndex].status = "3"
            self.eachOngoingScheduleTableView.reloadData()
            self.createAlert(alertTitle: "Request to change schedule successful", alertMessage: "Please wait for your trainer change schedule")
        }
        
    }
    
    @objc func reviewBtnAction(sender: UIButton) {
        
        self.parent?.performSegue(withIdentifier: "EachOngoingProgressToReview", sender: sender.tag)
    }
}
