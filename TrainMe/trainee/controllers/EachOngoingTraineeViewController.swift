//
//  EachOngoingTraineeViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 8/12/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit

class EachOngoingTraineeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var eachOngoingScheduleTableView: UITableView!
    
    var selectedOngoing: OngoingDetail!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("EachOngoingTraineeViewController \(self.selectedOngoing)")
        
        self.eachOngoingScheduleTableView.dataSource = self
        self.eachOngoingScheduleTableView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.selectedOngoing.eachOngoingDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EachOngoingTableViewCell") as! EachOngoingTraineeTableViewCell
        cell.countLb.text = self.selectedOngoing.eachOngoingDetails[indexPath.row].count
        cell.dateAndTimeLb.text = "\(self.selectedOngoing.eachOngoingDetails[indexPath.row].start_train_date) \(self.selectedOngoing.eachOngoingDetails[indexPath.row].start_train_time)"
        cell.statusLb.text = self.selectedOngoing.eachOngoingDetails[indexPath.row].status
        
        return cell
    }
}
