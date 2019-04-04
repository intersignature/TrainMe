//
//  AddCreditCardViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 26/11/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import Stripe
import CreditCardForm
import OmiseSDK
import DTTextField
import FirebaseAuth
import FirebaseDatabase

class AddCreditCardViewController: UIViewController, STPPaymentCardTextFieldDelegate, UITextFieldDelegate {

    @IBOutlet weak var creditCardForm: CreditCardFormView!
    
    let paymentTextField = STPPaymentCardTextField()
    let cardHolderTextField: UITextField! = UITextField()
    let confirmBtn = UIButton()
    
    let currentUser = Auth.auth().currentUser
    let ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.HideKeyboard()

        self.paymentTextField.delegate = self
//        self.cardHolderTextField.delegate = self
    }
    
    @IBAction func cancelBtnAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setupStripTextField() {
        
        paymentTextField.frame = CGRect(x: 15, y: 199, width: self.view.frame.size.width - 30, height: 44)
        paymentTextField.translatesAutoresizingMaskIntoConstraints = false
        paymentTextField.borderWidth = 0
        paymentTextField.backgroundColor = UIColor.clear
        paymentTextField.textColor = UIColor.white
        paymentTextField.tintColor = UIColor.white
        paymentTextField.placeholderColor = UIColor.white
        
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.darkGray.cgColor
        border.frame = CGRect(x: 0, y: paymentTextField.frame.size.height - width, width: paymentTextField.frame.size.width, height: paymentTextField.frame.size.height)
        border.borderWidth = width
        paymentTextField.layer.addSublayer(border)
        paymentTextField.layer.masksToBounds = true
        
        view.addSubview(paymentTextField)
        
        NSLayoutConstraint.activate([
            paymentTextField.topAnchor.constraint(equalTo: creditCardForm.bottomAnchor, constant: 20),
            paymentTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            paymentTextField.widthAnchor.constraint(equalToConstant: self.view.frame.size.width-20),
            paymentTextField.heightAnchor.constraint(equalToConstant: 44)
            ])
    }
    
    func setupCardHolderTextField() {
        
        cardHolderTextField.frame = CGRect(x: 15, y: 199, width: self.view.frame.size.width - 30, height: 44)
        cardHolderTextField.translatesAutoresizingMaskIntoConstraints = false
        cardHolderTextField.layer.borderWidth = 0
        cardHolderTextField.layer.borderColor = UIColor.clear.cgColor
        cardHolderTextField.layer.backgroundColor = UIColor.clear.cgColor
        cardHolderTextField.layer.shadowColor = UIColor.clear.cgColor
        cardHolderTextField.backgroundColor = UIColor.clear
        cardHolderTextField.textColor = UIColor.white
        cardHolderTextField.tintColor = UIColor.white
        cardHolderTextField.attributedPlaceholder = NSAttributedString(string: "card_holder".localized(), attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.darkGray.cgColor
        border.frame = CGRect(x: 0, y: cardHolderTextField.frame.size.height - width, width: cardHolderTextField.frame.size.width, height: cardHolderTextField.frame.size.height)
        border.borderWidth = width
        cardHolderTextField.layer.addSublayer(border)
        cardHolderTextField.layer.masksToBounds = true
        
        view.addSubview(cardHolderTextField)
        
        NSLayoutConstraint.activate([
            cardHolderTextField.topAnchor.constraint(equalTo: paymentTextField.bottomAnchor, constant: 20),
            cardHolderTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardHolderTextField.widthAnchor.constraint(equalToConstant: self.view.frame.size.width-20),
            cardHolderTextField.heightAnchor.constraint(equalToConstant: 44)
            ])
        
        cardHolderTextField.addTarget(self, action: #selector(self.updateCardHolderInCreditCardForm), for: .editingDidEnd)
    }
    
    func setupConfirmButton() {
        
        confirmBtn.layer.cornerRadius = 17
        confirmBtn.frame = CGRect(x: 15, y: 199, width: self.view.frame.size.width - 30, height: 30)
        confirmBtn.translatesAutoresizingMaskIntoConstraints = false
        confirmBtn.tintColor = UIColor.clear
        confirmBtn.layer.borderColor = UIColor.clear.cgColor
        confirmBtn.layer.backgroundColor = UIColor.clear.cgColor
        confirmBtn.layer.shadowColor = UIColor.clear.cgColor
        confirmBtn.backgroundColor = UIColor(red: 0/255.0, green: 207/255.0, blue: 207/255.0, alpha: 1)
        confirmBtn.titleLabel?.font = UIFont(name: "Noto Sans", size: CGFloat(15.0))
        confirmBtn.setTitle("add_credit_card".localized(), for: .normal)
        
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.white.cgColor
        border.frame = CGRect(x: 0, y: confirmBtn.frame.size.height - width, width: confirmBtn.frame.size.width, height: confirmBtn.frame.size.height)
        border.borderWidth = width
        confirmBtn.layer.addSublayer(border)
        confirmBtn.layer.masksToBounds = true
        
        view.addSubview(confirmBtn)
        
        NSLayoutConstraint.activate([
            confirmBtn.topAnchor.constraint(equalTo: cardHolderTextField.bottomAnchor, constant: 20),
            confirmBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            confirmBtn.widthAnchor.constraint(equalToConstant: self.view.frame.size.width-20),
            confirmBtn.heightAnchor.constraint(equalToConstant: 30)
            ])
        
        confirmBtn.addTarget(self, action: #selector(self.addCreditCardAction), for: .touchUpInside)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        paymentTextField.resignFirstResponder()
        cardHolderTextField.resignFirstResponder()
        self.dismissKeyboard()
        return true
    }
    
    @objc func updateCardHolderInCreditCardForm(textField: DTTextField) {
        
        print(cardHolderTextField.text!)
        creditCardForm.cardHolderString = cardHolderTextField.text!
    }
    
    @objc func addCreditCardAction() {
        
        print(paymentTextField.isValid)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.view.showBlurLoader()
        if paymentTextField.isValid && cardHolderTextField.text != "" {
            
            getCreditCardToken()
        } else {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.view.removeBluerLoader()
            self.createAlert(alertTitle: "card_information_is_not_valid".localized(), alertMessage: "")
        }
    }
    
    func getCreditCardToken() {
        
        let pkey = String(format: "%@:", "pkey_test_5e2xuwqwivt0h2npcje").data(using: String.Encoding.utf8)!.base64EncodedString()
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        guard let URL = URL(string: "https://vault.omise.co/tokens") else {return}
        
        var request = URLRequest(url: URL)
        request.httpMethod = "POST"
        
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("Basic \(String(describing: pkey))", forHTTPHeaderField: "Authorization")
        
        let params = "card[name]=\(cardHolderTextField.text!)&card[number]=\(paymentTextField.cardNumber!)&card[expiration_month]=\(paymentTextField.expirationMonth)&card[expiration_year]=\(paymentTextField.expirationYear)&card[security_code]=\(paymentTextField.cvc!)"
        request.httpBody = params.data(using: .utf8, allowLossyConversion: true)
        let task = session.dataTask(with: request) { (data, response, err) in
            if err == nil {
                let statusCode = (response as! HTTPURLResponse).statusCode
                if statusCode == 200 {
                    let jsonData = try! JSONSerialization.jsonObject(with: data!, options: []) as AnyObject
                    self.checkOmiseCusId(tokenId: jsonData["id"] as! String)
                }
            }
            else {
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                self.view.removeBluerLoader()
                print(err?.localizedDescription)
                self.createAlert(alertTitle: (err?.localizedDescription)!, alertMessage: "")
            }
        }
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
    func checkOmiseCusId(tokenId: String) {
        
        self.ref.child("user").child((self.currentUser?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as! NSDictionary
            if value["omise_cus_id"] as! String != "-1" {
                let omiseCusId = value["omise_cus_id"] as! String
                self.createOmiseCustomerWithCustomerId(tokenId: tokenId, omiseCusid: omiseCusId)
            } else if value["omise_cus_id"] as! String == "-1" {
                self.createOmiseCustomerWithOutCustomerId(tokenId: tokenId, email: value["email"] as! String)
            }
        }) { (err) in
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.view.removeBluerLoader()
            print(err.localizedDescription)
            self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
            return
        }
    }
    
    func createOmiseCustomerWithCustomerId(tokenId: String, omiseCusid: String) {
        
        let skey = String(format: "%@:", "skey_test_5dm3tm6pj69glowba1n").data(using: String.Encoding.utf8)!.base64EncodedString()
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        guard let URL = URL(string: "https://api.omise.co/customers/\(omiseCusid)") else {return}
        
        var request = URLRequest(url: URL)
        request.httpMethod = "PATCH"
        
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("Basic \(String(describing: skey))", forHTTPHeaderField: "Authorization")
        
        let params = "card=\(tokenId)"
        request.httpBody = params.data(using: .utf8, allowLossyConversion: true)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.view.removeBluerLoader()
        let task = session.dataTask(with: request) { (data, response, err) in
            
            if err == nil {
                let statusCode = (response as! HTTPURLResponse).statusCode
                let jsonData = try! JSONSerialization.jsonObject(with: data!, options: []) as AnyObject
                
                if statusCode == 200 {
                    print(jsonData)
                    let alert = UIAlertController(title: "add_credit_card_successful".localized(), message: "", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: { (action) in
                        self.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                } else if statusCode == 404 {
                    print(jsonData["message"] as! String)
                    self.createAlert(alertTitle: jsonData["message"] as! String, alertMessage: "")
                }
            } else {
                print(err?.localizedDescription)
                self.createAlert(alertTitle: err!.localizedDescription, alertMessage: "")
            }
        }
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
    func createOmiseCustomerWithOutCustomerId(tokenId: String, email: String) {
        
        let skey = String(format: "%@:", "skey_test_5dm3tm6pj69glowba1n").data(using: String.Encoding.utf8)!.base64EncodedString()
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        guard let URL = URL(string: "https://api.omise.co/customers") else {return}
        
        var request = URLRequest(url: URL)
        request.httpMethod = "POST"
        
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("Basic \(String(describing: skey))", forHTTPHeaderField: "Authorization")
        
        let params = "description=\(self.currentUser!.uid)&email=\(email)&card=\(tokenId)"
        request.httpBody = params.data(using: .utf8, allowLossyConversion: true)
        
        let task = session.dataTask(with: request) { (data, response, err) in
            if err == nil {
                let statusCode = (response as! HTTPURLResponse).statusCode
                if statusCode == 200 {
                    let jsonData = try! JSONSerialization.jsonObject(with: data!, options: []) as AnyObject
                    print(jsonData)
                    self.addOmiseCusIdToDatabase(omiseCusId: jsonData["id"] as! String)
                }
            } else {
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                self.view.removeBluerLoader()
                print(err?.localizedDescription)
                self.createAlert(alertTitle: err!.localizedDescription, alertMessage: "")
            }
        }
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
    func addOmiseCusIdToDatabase(omiseCusId: String) {
        
        let omiseCusIdData = ["omise_cus_id": omiseCusId]
        
        self.ref.child("user").child(self.currentUser!.uid).updateChildValues(omiseCusIdData) { (err, ref) in
            if let err = err {
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                self.view.removeBluerLoader()
                print(err.localizedDescription)
                self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                return
            }
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.view.removeBluerLoader()

            let alert = UIAlertController(title: "add_credit_card_successful".localized(), message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: { (action) in
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
        creditCardForm.paymentCardTextFieldDidChange(cardNumber: textField.cardNumber, expirationYear: textField.expirationYear, expirationMonth: textField.expirationMonth, cvc: textField.cvc)
    }
    
    func paymentCardTextFieldDidEndEditingExpiration(_ textField: STPPaymentCardTextField) {
        creditCardForm.paymentCardTextFieldDidEndEditingExpiration(expirationYear: textField.expirationYear)
    }
    
    func paymentCardTextFieldDidBeginEditingCVC(_ textField: STPPaymentCardTextField) {
        creditCardForm.paymentCardTextFieldDidBeginEditingCVC()
    }
    
    func paymentCardTextFieldDidEndEditingCVC(_ textField: STPPaymentCardTextField) {
        creditCardForm.paymentCardTextFieldDidEndEditingCVC()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        self.setupNavigationStyle()
        
        self.title = "add_credit_card".localized()
        
        self.setupStripTextField()
        self.setupCardHolderTextField()
        self.setupConfirmButton()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
    }
}
