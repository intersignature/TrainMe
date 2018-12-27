//
//  SidebarViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 27/8/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage

class SidebarTrainerViewController: UIViewController {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var emailLb: UILabel!
    @IBOutlet weak var userProfileBtn: UIButton!
    @IBOutlet weak var creditcardBtn: UIButton!
    @IBOutlet weak var helpBtn: UIButton!
    @IBOutlet weak var settingsBtn: UIButton!
    @IBOutlet weak var logoutBtn: UIButton!
    private var currentUser: User?
    
    @IBAction func logoutBtnAction(_ sender: UIButton) {
        
        try! Auth.auth().signOut()
        performSegue(withIdentifier: "LogoutSeg", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        currentUser = Auth.auth().currentUser
        setProfileImageRound()

        print(currentUser?.displayName)
        print(currentUser?.photoURL?.absoluteString)
        
        nameLb.text = currentUser?.displayName
        emailLb.text = currentUser?.email
        
        setLocalizeText()
        
        if currentUser?.photoURL != nil {
            profileImg.downloaded(from: (currentUser?.photoURL)!)
        } else {
            // profileImg.downloaded(from: (Auth.auth().currentUser?.photoURL)!) -> use default image link
        }
    }

    func setLocalizeText() {
        
        userProfileBtn.setTitle(NSLocalizedString("user_profile", comment: ""), for: .normal)
        creditcardBtn.setTitle(NSLocalizedString("credit_card_paypal", comment: ""), for: .normal)
        helpBtn.setTitle(NSLocalizedString("help", comment: ""), for: .normal)
        settingsBtn.setTitle(NSLocalizedString("settings", comment: ""), for: .normal)
        logoutBtn.setTitle(NSLocalizedString("logout", comment: ""), for: .normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setProfileImageRound() {
        
        profileImg.layer.borderWidth = 10
        profileImg.layer.masksToBounds = false
        profileImg.layer.borderColor = UIColor(red: 51/255.0, green: 51/255.0, blue: 153/255.0, alpha: 1).cgColor
        profileImg.layer.cornerRadius = profileImg.frame.height/2
        profileImg.clipsToBounds = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SidebarTrainerToProfileTrainer" {
            let vc = segue.destination as! UINavigationController
            let containeVc = vc.topViewController as! ProfileTrainerViewController
            containeVc.isBlurProfileImage = false
        }
    }
    
    @IBAction func profileBtnAction(_ sender: UIButton) {
        performSegue(withIdentifier: "SidebarTrainerToProfileTrainer", sender: self.currentUser?.uid)
    }
    @IBAction func creditcardBtnAction(_ sender: UIButton) {
        performSegue(withIdentifier: "SidebarTrainerToCreditCard", sender: nil)
    }
}
