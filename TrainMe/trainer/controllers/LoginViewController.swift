//
//  LoginViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 21/8/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var emailTf: UITextField!
    @IBOutlet weak var passwordTf: UITextField!
    @IBOutlet weak var loginLb: UILabel!
    @IBOutlet weak var forgetPasswordBtn: UIButton!
    
    var ref: DatabaseReference!
    var role = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        emailView.layer.cornerRadius = 17
        passwordView.layer.cornerRadius = 17
        loginBtn.layer.cornerRadius = 17
        
        emailView.backgroundColor = UIColor(white: 1, alpha: 0.3)
        emailTf.backgroundColor = UIColor(white: 1, alpha: 0)
        passwordView.backgroundColor = UIColor(white: 1, alpha: 0.3)
        passwordTf.backgroundColor = UIColor(white: 1, alpha: 0)
        
        self.emailTf.delegate = self
        self.passwordTf.delegate = self

        self.HideKeyboard()
        self.setLocalizeText()
    }

    func setLocalizeText() {
        
        loginBtn.setTitle(NSLocalizedString("login", comment: ""), for: .normal)
        emailTf.placeholder = NSLocalizedString("email", comment: "")
        passwordTf.placeholder = NSLocalizedString("password", comment: "")
        loginLb.text = NSLocalizedString("login", comment: "")
        forgetPasswordBtn.setTitle(NSLocalizedString("forget_password", comment: ""), for: .normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        emailTf.resignFirstResponder()
        passwordTf.resignFirstResponder()
        return true
    }
    
    @IBAction func LoginBtnAction(_ sender: UIButton) {
        
        if self.emailTf.text == "" || self.passwordTf.text == "" {
            createAlert(alertTitle: NSLocalizedString("please_enter_your_email", comment: ""), alertMessage: "")
            return
        }
        if !(self.emailTf.text?.isValidEmail())! {
            createAlert(alertTitle: NSLocalizedString("please_enter_your_valid_email", comment: ""), alertMessage: "")
            return
        }
        self.view.showBlurLoader()
        Auth.auth().signIn(withEmail: emailTf.text!, password: passwordTf.text!) { (result, err) in
            if let err = err {
                print(err)
                self.view.removeBluerLoader()
//                self.dismiss(animated: false, completion: nil)
                self.createAlert(alertTitle:err.localizedDescription, alertMessage: "")
                return
            }
            self.getRole()
            
            // Remark: Get verify email
//            if (Auth.auth().currentUser?.isEmailVerified)! {
//                self.getRole()
//            }
//            else {
//                try! Auth.auth().signOut()
//                self.view.removeBluerLoader()
//                self.createAlert(alertTitle: "Please verify email", alertMessage: "")
//            }
        }
    }
    
    @IBAction func backBtnAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getRole() {
        
        let uid = Auth.auth().currentUser?.uid
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        ref.child("user").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            self.role = value?["role"]! as! String
            let isBan = value!["ban"] as! Bool
            
            if isBan {
                try! Auth.auth().signOut()
                self.view.removeBluerLoader()
                self.createAlert(alertTitle: "Your account was banned by admin", alertMessage: "")
                return
            }
            
            self.view.removeBluerLoader()
            if self.role == "trainer" {
                self.performSegue(withIdentifier: "LoginToMain", sender: nil)
            }
            if self.role == "trainee" {
                print("1")
                self.performSegue(withIdentifier: "LoginToMainTrainee", sender: nil)
            }
        }) { (err) in
            print(err.localizedDescription)
        }
    }
}
