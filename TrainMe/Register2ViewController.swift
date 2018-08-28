//
//  Register2ViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 22/8/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit

class Register2ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var text: UILabel!
    var str = String()
    var userProfile: UserProfile = UserProfile()
    
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var verifyPasswordView: UIView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var emailTf: UITextField!
    @IBOutlet weak var passwordTf: UITextField!
    @IBOutlet weak var verifyPasswordTf: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
//        text.text = str
        
        emailView.layer.cornerRadius = 17
        passwordView.layer.cornerRadius = 17
        verifyPasswordView.layer.cornerRadius = 17
        nextBtn.layer.cornerRadius = 17
        
        self.emailTf.delegate = self
        self.passwordTf.delegate = self
        self.verifyPasswordTf.delegate = self
        
        self.HideKeyboard()
        
        print(self.userProfile.getData())
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
    
    func nextTransition(segueId: String) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        view.window!.layer.add(transition, forKey: kCATransition)
        performSegue(withIdentifier: segueId, sender: self)
    }
    
    @IBAction func backBtnAction(_ sender: UIButton) {
        backTrainsition(segueId: "Register2ToRegister")
    }
    
    @IBAction func nextBtnAction(_ sender: UIButton) {
        if emailTf.text == "" {
            createAlert(alertTitle: "Please enter your email", alertMessage: "")
            return
        }
        if !isValidEmail(testStr: emailTf.text!) {
            createAlert(alertTitle: "Please enter your valid email", alertMessage: "")
            return
        }
        if passwordTf.text == "" {
            createAlert(alertTitle: "Please enter your password", alertMessage: "")
            return
        }
        if verifyPasswordTf.text == "" {
            createAlert(alertTitle: "Please enter your verify password", alertMessage: "")
            return
        }
        if (passwordTf.text?.count)! < 8 {
            createAlert(alertTitle: "Please enter your password at least 8 characters", alertMessage: "")
            return
        }
        if passwordTf.text! != verifyPasswordTf.text {
            createAlert(alertTitle: "Your password doesn't match", alertMessage: "")
            return
        } else {
            nextTransition(segueId: "Register2ToRegister3")
        }
    }
    
    func createAlert(alertTitle: String, alertMessage: String) {
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
