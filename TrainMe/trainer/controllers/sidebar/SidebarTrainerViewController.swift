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
    @IBOutlet weak var creditcardBtn: UIButton!
    @IBOutlet weak var helpBtn: UIButton!
    @IBOutlet weak var settingsBtn: UIButton!
    @IBOutlet weak var logoutBtn: UIButton!
    @IBOutlet weak var seperateView: UIView!
    @IBOutlet weak var topSidebarView: UIView!
    
    private var currentUser: User?
    
    @IBAction func logoutBtnAction(_ sender: UIButton) {
        
        try! Auth.auth().signOut()
        performSegue(withIdentifier: "LogoutSeg", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        currentUser = Auth.auth().currentUser

        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.topSidebarViewAction(_:)))
        self.topSidebarView.addGestureRecognizer(gesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setLocalizeText()
        
        self.emailLb.textColor = UIColor.white.withAlphaComponent(0.4)
        self.seperateView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        nameLb.text = currentUser?.displayName
        emailLb.text = currentUser?.email
        if currentUser?.photoURL != nil {
            profileImg.downloaded(from: (self.currentUser?.photoURL?.absoluteString)!)
        } else {
            // profileImg.downloaded(from: (Auth.auth().currentUser?.photoURL)!) -> use default image link
        }
    }

    func setLocalizeText() {
        
        creditcardBtn.setTitle("bank_account".localized(), for: .normal)
        helpBtn.setTitle("help".localized(), for: .normal)
        settingsBtn.setTitle("settings".localized(), for: .normal)
        logoutBtn.setTitle("logout".localized(), for: .normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func topSidebarViewAction(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "SidebarTrainerToProfileTrainer", sender: self.currentUser?.uid)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SidebarTrainerToProfileTrainer" {
            let vc = segue.destination as! UINavigationController
            let containeVc = vc.topViewController as! ProfileTrainerViewController
            containeVc.isBlurProfileImage = false
            containeVc.trainerProfileUid = self.currentUser?.uid
        }
    }
}
