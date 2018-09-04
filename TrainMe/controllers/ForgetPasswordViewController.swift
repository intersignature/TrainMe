//
//  ForgetPasswordViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 21/8/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import FirebaseAuth

class ForgetPasswordViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var emailTf: UITextField!
    @IBOutlet weak var recoveryYourAccLb: UILabel!
    @IBOutlet weak var recoveryYourAccDesLb: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailView.layer.cornerRadius = 17
        sendBtn.layer.cornerRadius = 17
        
        self.emailTf.delegate = self
        
        self.HideKeyboard()
        setLocalizeText()
    }
    
    func setLocalizeText() {
        
        recoveryYourAccLb.text = NSLocalizedString("recovery_your_account", comment: "")
        recoveryYourAccDesLb.text = NSLocalizedString("recovery_your_account_description", comment: "")
        emailTf.placeholder = NSLocalizedString("email", comment: "")
        sendBtn.setTitle(NSLocalizedString("send", comment: ""), for: .normal)
    }
    
    @IBAction func backBtnAction(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        emailTf.resignFirstResponder()
        return true
    }
    
    @IBAction func sendBtnAction(_ sender: UIButton) {
        
        if emailTf.text == "" {
            createAlert(alertTitle: NSLocalizedString("please_enter_your_email", comment: ""), alertMessage: "")
        } else {
            self.view.showBlurLoader()
            sendRecoveryEmail()
        }
    }
    
    func sendRecoveryEmail() {
        
        Auth.auth().sendPasswordReset(withEmail: emailTf.text!) { (err) in
            if let err = err {
                self.view.removeBluerLoader()
                self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                return
            }
            self.view.removeBluerLoader()
            self.createAlert(alertTitle: NSLocalizedString("send_email_for_reset_password_success", comment: ""), alertMessage: "")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
