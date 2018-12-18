//
//  EachOngoingTraineeViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 8/12/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import FirebaseAuth


class EachOngoingTraineeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var eachOngoingScheduleTableView: UITableView!
    
    var selectedOngoing: OngoingDetail!
    var currentUser: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("EachOngoingTraineeViewController \(self.selectedOngoing)")
        
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
        return cell
    }
    
    @objc func requestScheduleBtnAction(sender: UIButton) {
        
        let alert = UIAlertController(title: "Confirm to request change schedule?", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            print("Confirm to request")
            //TODO: request
        }))
        alert.addAction(UIAlertAction(title: "No", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func reviewBtnAction(sender: UIButton) {
        
        self.parent?.performSegue(withIdentifier: "EachOngoingProgressToReview", sender: sender.tag)
    }
}
