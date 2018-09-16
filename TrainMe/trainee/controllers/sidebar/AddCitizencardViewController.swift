//
//  AddCitizencardViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 16/9/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import FirebaseAuth

class AddCitizencardViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        print("---\(String(describing: Auth.auth().currentUser?.displayName))---\(String(describing: Auth.auth().currentUser?.email))---\(String(describing: Auth.auth().currentUser?.uid))")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupNavigationStyle()
    }
}
