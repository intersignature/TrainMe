//
//  ChangePasswordViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 29/12/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import FirebaseAuth
import DTTextField

class ChangePasswordViewController: UIViewController {

    @IBOutlet weak var oldPasswordLb: UILabel!
    @IBOutlet weak var oldPasswordTf: UITextField!
    @IBOutlet weak var newPasswordLb: UILabel!
    @IBOutlet weak var newPasswordTf: UITextField!
    @IBOutlet weak var confirmNewPasswordLb: UILabel!
    @IBOutlet weak var confirmNewPasswordTf: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var seperateView1: UIView!
    @IBOutlet weak var seperateView2: UIView!
    @IBOutlet weak var seperateView3: UIView!
    
    var currentUser: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.currentUser = Auth.auth().currentUser
        
        self.HideKeyboard()
        
        self.saveBtn.layer.cornerRadius = 17
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "change_password".localized()
        
        self.oldPasswordLb.text = "old_password".localized()
        self.newPasswordLb.text = "new_password".localized()
        self.confirmNewPasswordLb.text = "confirm_new_password".localized()
        self.oldPasswordTf.attributedPlaceholder = NSAttributedString(string: "old_password".localized(), attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        self.newPasswordTf.attributedPlaceholder = NSAttributedString(string: "new_password".localized(), attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        self.confirmNewPasswordTf.attributedPlaceholder = NSAttributedString(string: "confirm_new_password".localized(), attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        self.saveBtn.setTitle("save".localized(), for: .normal)
        
        self.seperateView1.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        self.seperateView2.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        self.seperateView3.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
    }
    
    @IBAction func saveBtnAction(_ sender: UIButton) {
        
        if checkPassword() {
            let credential = EmailAuthProvider.credential(withEmail: self.currentUser.email!, password: self.oldPasswordTf.text!)
            self.currentUser.reauthenticateAndRetrieveData(with: credential) { (result, err) in
                if let err = err {
                    self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                    print(err.localizedDescription)
                    return
                }
                self.currentUser.updatePassword(to: self.newPasswordTf.text!, completion: { (err1) in
                    if let err1 = err1 {
                        self.createAlert(alertTitle: err1.localizedDescription, alertMessage: "")
                        print(err1.localizedDescription)
                        return
                    }
                    let alert = UIAlertController(title: "change_password_successful".localized(), message: "", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: { (action) in
                        self.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                })
            }
        }
    }
    
    func checkPassword() -> Bool{
        
        if oldPasswordTf.text == "" || newPasswordTf.text == "" || confirmNewPasswordTf.text == "" {
            self.createAlert(alertTitle: "please_fill_in_the_blank".localized(), alertMessage: "")
            return false
        } else if oldPasswordTf.text != newPasswordTf.text {
            self.createAlert(alertTitle: "old_password_and_new_password_does_not_match".localized(), alertMessage: "")
            return false
        }
        return true
    }
    
    @IBAction func cancelBtnAction(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
    }
}
