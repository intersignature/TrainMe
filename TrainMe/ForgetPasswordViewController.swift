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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailView.layer.cornerRadius = 17
        sendBtn.layer.cornerRadius = 17
        
        self.emailTf.delegate = self
        
        self.HideKeyboard()

        // Do any additional setup after loading the view.
    }

    
    @IBAction func backBtnAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTf.resignFirstResponder()
        
        return true
    }
    @IBAction func sendBtnAction(_ sender: UIButton) {
        Auth.auth().sendPasswordReset(withEmail: emailTf.text!) { (err) in
            if let err = err {
                self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                return
            }
            self.createAlert(alertTitle: "Send email for reset password successfully!", alertMessage: "")
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
