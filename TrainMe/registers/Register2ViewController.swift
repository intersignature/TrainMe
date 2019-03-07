//
//  Register2ViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 22/8/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import FirebaseAuth
import DTTextField

class Register2ViewController: UIViewController, UITextFieldDelegate {

    var str = String()
    var userProfile: UserProfile = UserProfile()
    
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var verifyPasswordView: UIView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var emailTf: DTTextField!
    @IBOutlet weak var passwordTf: DTTextField!
    @IBOutlet weak var verifyPasswordTf: DTTextField!
    @IBOutlet weak var registerLb: UILabel!
    @IBOutlet weak var emailDescription: UILabel!
    @IBOutlet weak var passwordDescription: UILabel!
    @IBOutlet weak var verifyPasswordDescriptionLb: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailView.layer.cornerRadius = 17
        passwordView.layer.cornerRadius = 17
        verifyPasswordView.layer.cornerRadius = 17
        nextBtn.layer.cornerRadius = 17
        
        emailView.backgroundColor = UIColor(white: 1, alpha: 0.3)
        emailTf.backgroundColor = UIColor(white: 1, alpha: 0)
        passwordView.backgroundColor = UIColor(white: 1, alpha: 0.3)
        passwordTf.backgroundColor = UIColor(white: 1, alpha: 0)
        verifyPasswordView.backgroundColor = UIColor(white: 1, alpha: 0.3)
        verifyPasswordTf.backgroundColor = UIColor(white: 1, alpha: 0)
        
        self.emailTf.delegate = self
        self.passwordTf.delegate = self
        self.verifyPasswordTf.delegate = self
        
        self.HideKeyboard()
        
        setLocalizeText()
        
        print(self.userProfile.getData())
    }
    
    func setLocalizeText() {
        
        registerLb.text = "register".localized()
        emailTf.placeholder = "email".localized()
        emailDescription.text = "email_description".localized()
        passwordTf.placeholder = "password".localized()
        passwordDescription.text = "password_description".localized()
        verifyPasswordTf.placeholder = "verify_password".localized()
        verifyPasswordDescriptionLb.text = "verify_password_description".localized()
        nextBtn.setTitle("next".localized(), for: .normal)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        emailTf.resignFirstResponder()
        passwordTf.resignFirstResponder()
        verifyPasswordTf.resignFirstResponder()
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let register3Vc = segue.destination as? Register3ViewController {
            register3Vc.userProfile = self.userProfile
            register3Vc.email = emailTf.text
            register3Vc.password = passwordTf.text
        }
    }
    
    func backTrainsition(segueId: String) {
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        view.window!.layer.add(transition, forKey: kCATransition)
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func backBtnAction(_ sender: UIButton) {
        
//        backTrainsition(segueId: "Register2ToRegister")
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextBtnAction(_ sender: UIButton) {
        
        if emailTf.text == "" {
            createAlert(alertTitle: "please_enter_your_email".localized(), alertMessage: "")
            return
        }
        if !(emailTf.text?.isValidEmail())! {
            createAlert(alertTitle: "please_enter_your_valid_email".localized(), alertMessage: "")
            return
        }
        if passwordTf.text == "" {
            createAlert(alertTitle: "please_enter_your_password".localized(), alertMessage: "")
            return
        }
        if verifyPasswordTf.text == "" {
            createAlert(alertTitle: "please_enter_your_verify_password".localized(), alertMessage: "")
            return
        }
        if (passwordTf.text?.count)! < 8 {
            createAlert(alertTitle: "please_enter_your_password_at_least_8_characters".localized(), alertMessage: "")
            return
        }
        if passwordTf.text! != verifyPasswordTf.text {
            createAlert(alertTitle: "your_password_doesnt_match".localized(), alertMessage: "")
            return
        }
        Auth.auth().fetchSignInMethods(forEmail: self.emailTf.text!) { signInMethods, error in
            if ((error) != nil) {
                print(error?.localizedDescription)
                return
            }
            if signInMethods == nil {
                print("can regis")
                self.userProfile.email = self.emailTf.text!
                self.performSegue(withIdentifier: "Register2ToRegister3", sender: nil)
            } else {
                print("can not regis")
                self.createAlert(alertTitle: "email_is_already_in_use".localized(), alertMessage: "")
                return
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
