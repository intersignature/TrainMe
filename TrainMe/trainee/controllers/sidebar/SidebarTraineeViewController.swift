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
    @IBOutlet weak var creditCardBtn: UIButton!
    @IBOutlet weak var helpBtn: UIButton!
    @IBOutlet weak var settingBtn: UIButton!
    @IBOutlet weak var becomeATrainerBtn: UIButton!
    @IBOutlet weak var logoutBtn: UIButton!
    @IBOutlet weak var seperateView: UIView!
    @IBOutlet weak var topSidebarView: UIView!
    
    private var currentUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentUser = Auth.auth().currentUser
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.topSidebarViewAction(_:)))
        self.topSidebarView.addGestureRecognizer(gesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setLocalizeText()
        
        emailLb.textColor = UIColor.white.withAlphaComponent(0.4)
        self.seperateView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        nameLb.text = currentUser?.displayName
        emailLb.text = currentUser?.email
        if currentUser?.photoURL != nil {
            profileImg.downloaded(from: (currentUser?.photoURL?.absoluteString)!)
            self.setProfileImageRound()
        } else {
            // profileImg.downloaded(from: (Auth.auth().currentUser?.photoURL)!) -> use default image link
        }
    }
    
    func setLocalizeText() {
        self.creditCardBtn.setTitle("     \("credit_card_paypal".localized())", for: .normal)
        self.helpBtn.setTitle("     \("help".localized())", for: .normal)
        self.settingBtn.setTitle("     \("settings".localized())", for: .normal)
        self.becomeATrainerBtn.setTitle("     \("become_a_trainer".localized())", for: .normal)
        self.logoutBtn.setTitle("     \("logout".localized())", for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func topSidebarViewAction(_ sender: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: "SidebarTraineeToProfileTrainee", sender: self.currentUser?.uid)
    }
    
    @IBAction func logoutBtnAction(_ sender: UIButton) {
        try! Auth.auth().signOut()
        performSegue(withIdentifier: "LogoutTraineeSeg", sender: nil)
    }
    
    @IBAction func creditCardBtnAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: "SidebarToCreditcardView", sender: nil)
    }
    
    @IBAction func becomeATrainerBtnAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: "SidebarTraineeToBecomeToATrainer", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "SidebarTraineeToProfileTrainee" {
            
            let vc = segue.destination as! UINavigationController
            let containVc = vc.topViewController as! ProfileTraineeViewController
            containVc.isBlurProfile = false
            containVc.traineeProfileUid = self.currentUser?.uid
        }
    }
    
    func setProfileImageRound() {
        
        self.profileImg.layer.masksToBounds = false
        self.profileImg.layer.cornerRadius = self.profileImg.frame.height/2
        self.profileImg.clipsToBounds = true
    }
}
