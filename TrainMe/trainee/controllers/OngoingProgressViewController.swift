//
//  OngoingProgressViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 3/12/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit

class OngoingProgressViewController: UIViewController {

    var selectedTrainer: UserProfile!
    var selectedCourse: Course!
    var selectedOngoing: OngoingDetail!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("selectedOngoing: \(self.selectedOngoing.eachOngoingDetails)")
    }
    
    @IBAction func cancelBtnAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupNavigationStyle()
    }
}
