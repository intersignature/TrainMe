//
//  HelpTrainerViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 30/12/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class HelpViewController: UIViewController {
    
    var ref: DatabaseReference!
    var currentUser: User!
    var userRole: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ref = Database.database().reference()
        self.currentUser = Auth.auth().currentUser
        
        self.getRole()
    }
    
    func getRole() {
        
        self.ref.child("user").child(self.currentUser.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let values = snapshot.value as? NSDictionary
            self.userRole = values!["role"] as? String
            print(self.userRole)
        }) { (err) in
            self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
            print(err.localizedDescription)
            return
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupNavigationStyle()
    }
    
    @IBAction func cancelBtnAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}
