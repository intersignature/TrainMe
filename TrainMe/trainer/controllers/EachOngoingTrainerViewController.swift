//
//  EachOngoingTrainerViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 19/12/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import FirebaseDatabase

class EachOngoingTrainerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
   
    @IBOutlet weak var eachOngoingTrainerTableView: UITableView!
    
    var selectedOngoing: OngoingDetail!
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("selectedOngoingzz: \(selectedOngoing)")
        
        self.ref = Database.database().reference()
        
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
        cell.confirmSuccessTrainBtn.addTarget(self, action: #selector(self.confirmSuccessStatusToDatabase(sender:)), for: .touchUpInside)
        
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
    
    @objc func confirmSuccessStatusToDatabase(sender: UIButton) {
        
        //TODO: confirmSuccessStatusToDatabase
        print("confirmSuccessStatusToDatabase: \(sender.tag)")
    }
    
}
