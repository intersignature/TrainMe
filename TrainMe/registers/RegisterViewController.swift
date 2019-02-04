//
//  RegisterViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 21/8/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import DTTextField

class RegisterViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var registerLb: UILabel!
    @IBOutlet weak var fullnameTf: DTTextField!
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
    
    @IBAction func backBtnAction(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextBtnAction(_ sender: UIButton) {
        
        if fullnameTf.text == "" {
            createAlert(alertTitle: NSLocalizedString("please_enter_your_fullname", comment: ""), alertMessage: "")
            return
        } else {
            self.userProfile.fullName = fullnameTf.text!
            performSegue(withIdentifier: "RegisterToRegister2", sender: self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
