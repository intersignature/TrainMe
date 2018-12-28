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
    }
    
    func checkPassword() -> Bool{
        
        return true
    }
    
    @IBAction func cancelBtnAction(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
    }
}
