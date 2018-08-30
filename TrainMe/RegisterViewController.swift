//
//  RegisterViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 21/8/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit

extension UIViewController{
    func HideKeyboard() {
        let Tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        view.addGestureRecognizer(Tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

class RegisterViewController: UIViewController, UITextFieldDelegate{

    
    @IBOutlet weak var registerLb: UILabel!
    @IBOutlet weak var fullnameTf: UITextField!
    @IBOutlet weak var fullnameView: UIView!
    @IBOutlet weak var nextBtn: UIButton!
    var userProfile: UserProfile = UserProfile()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fullnameView.layer.cornerRadius = 17
        nextBtn.layer.cornerRadius = 17
        
        self.fullnameTf.delegate = self
        
        self.HideKeyboard()
        setLocalizeText()
        // Do any additional setup after loading the view.
    }
    
    func setLocalizeText() {
        registerLb.text = NSLocalizedString("register", comment: "")
        fullnameTf.placeholder = NSLocalizedString("full_name", comment: "")
        nextBtn.setTitle(NSLocalizedString("next", comment: ""), for: .normal)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        fullnameTf.resignFirstResponder()
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let register2Vc = segue.destination as? Register2ViewController {
            register2Vc.userProfile = self.userProfile
            
        }
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
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextBtnAction(_ sender: UIButton) {
        if fullnameTf.text == "" {
            createAlert(alertTitle: NSLocalizedString("please_enter_your_fullname", comment: ""), alertMessage: "")
            return
        } else {
            self.userProfile.fullName = fullnameTf.text!
            nextTransition(segueId: "RegisterToRegister2")
        }
    }
    
    func createAlert(alertTitle: String, alertMessage: String) {
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
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
