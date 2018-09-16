//
//  SidebarTraineeViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 15/9/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage

class SidebarTraineeViewController: UIViewController {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var emailLb: UILabel!
    private var currentUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentUser = Auth.auth().currentUser
        self.setProfileImageRound()
        
        nameLb.text = currentUser?.displayName
        emailLb.text = currentUser?.email
        
        if currentUser?.photoURL != nil {
            profileImg.downloaded(from: (currentUser?.photoURL)!)
        } else {
            // profileImg.downloaded(from: (Auth.auth().currentUser?.photoURL)!) -> use default image link
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    @IBAction func logoutBtnAction(_ sender: UIButton) {
        try! Auth.auth().signOut()
        performSegue(withIdentifier: "LogoutTraineeSeg", sender: nil)
    }
    
    func setProfileImageRound() {
        
        profileImg.layer.borderWidth = 10
        profileImg.layer.masksToBounds = false
        profileImg.layer.borderColor = UIColor(red: 51/255.0, green: 51/255.0, blue: 153/255.0, alpha: 1).cgColor
        profileImg.layer.cornerRadius = profileImg.frame.height/2
        profileImg.clipsToBounds = true
    }
}
