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

    @IBOutlet weak var oldPasswordTf: DTTextField!
    @IBOutlet weak var newPasswordTf: DTTextField!
    @IBOutlet weak var confirmNewPasswordTf: DTTextField!
    @IBOutlet weak var saveBtn: UIButton!
    
    var currentUser: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.currentUser = Auth.auth().currentUser
        
        self.HideKeyboard()
        
        self.saveBtn.layer.cornerRadius = 17
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupNavigationStyle()
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
                    let alert = UIAlertController(title: "Change password successfull", message: "", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        self.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                })
            }
        }
    }
    
    func checkPassword() -> Bool{
        
        return true
    }
    
    @IBAction func cancelBtnAction(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
    }
}
