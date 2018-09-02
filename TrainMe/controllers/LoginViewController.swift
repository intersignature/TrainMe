//
//  LoginViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 21/8/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var emailTf: UITextField!
    @IBOutlet weak var passwordTf: UITextField!
    @IBOutlet weak var loginLb: UILabel!
    @IBOutlet weak var forgetPasswordBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailView.layer.cornerRadius = 17
        passwordView.layer.cornerRadius = 17
        loginBtn.layer.cornerRadius = 17
        
        self.emailTf.delegate = self
        self.passwordTf.delegate = self

        self.HideKeyboard()
        self.setLocalizeText()

        // Do any additional setup after loading the view.
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
        // Dispose of any resources that can be recreated.
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
            self.view.removeBluerLoader()
            self.performSegue(withIdentifier: "LoginToMain", sender: nil)
        
        }
    }
    
    @IBAction func backBtnAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
