//
//  EditProfileTraineeViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 28/12/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit

class EditProfileTraineeViewController: UIViewController {

    var traineeProfile: UserProfile!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("EditProfileTraineeViewController \(self.traineeProfile)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupNavigationStyle()
    }
    
    @IBAction func cancelBtnAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}
