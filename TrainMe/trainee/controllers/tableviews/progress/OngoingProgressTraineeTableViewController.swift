//
//  OngoingProgressTraineeTableViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 5/12/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit

class OngoingProgressTraineeTableViewController: UITableViewController {

    var selectedTrainer: UserProfile!
    var selectedCourse: Course!
    var selectedOngoing: OngoingDetail!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 600
        
        print("selectedOngoing: \(self.selectedOngoing.eachOngoingDetails)")
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
    }

    @IBAction func cancelBtnAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupNavigationStyle()
    }
    
}
