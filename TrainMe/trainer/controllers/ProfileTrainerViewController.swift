//
//  ProfileViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 8/10/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit

class ProfileTrainerViewController: UIViewController {

    var trainerUid: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("nnn\(self.trainerUid)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupNavigationStyle()
    }
    
    @IBAction func cancelBtnAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}
