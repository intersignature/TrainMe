//
//  ProfileTraineeViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 20/12/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit

class ProfileTraineeViewController: UIViewController {

    var traineeUid: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("ProfileTraineeViewController \(String(describing: self.traineeUid))")
    }
    
    @IBAction func cancelBtnAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupNavigationStyle()
    }
}
