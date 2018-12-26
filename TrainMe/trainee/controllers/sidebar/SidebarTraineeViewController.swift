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
    @IBOutlet weak var profileBtn: UIButton!
    @IBOutlet weak var creditCardBtn: UIButton!
    @IBOutlet weak var helpBtn: UIButton!
    @IBOutlet weak var settingBtn: UIButton!
    @IBOutlet weak var becomeATrainerBtn: UIButton!
    @IBOutlet weak var logoutBtn: UIButton!
    
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
    
    @IBAction func creditCardBtnAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: "SidebarToCreditcardView", sender: nil)
    }
    
    @IBAction func profileBtnAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: "SidebarTraineeToProfileTrainee", sender: self.currentUser?.uid)
    }
    
    @IBAction func becomeATrainerBtnAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: "SidebarTraineeToBecomeToATrainer", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "SidebarTraineeToProfileTrainee" {
            
            let vc = segue.destination as! UINavigationController
            let containVc = vc.topViewController as! ProfileTraineeViewController
            containVc.isBlurProfile = false
        }
    }
}
