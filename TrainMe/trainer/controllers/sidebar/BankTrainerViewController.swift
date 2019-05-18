//
//  BankTrainerViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 15/1/2562 BE.
//  Copyright © 2562 Sirichai Binchai. All rights reserved.
//

import UIKit
import DTTextField
import FirebaseAuth
import FirebaseDatabase

class BankTrainerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var accountNameTf: UITextField!
    @IBOutlet weak var accountNumberTf: UITextField!
    @IBOutlet weak var bankNameTf: UITextField!
    @IBOutlet weak var confirmBtn: UIButton!
    
    @IBOutlet weak var accountNameLb: UILabel!
    @IBOutlet weak var accountNumberLb: UILabel!
    @IBOutlet weak var bankNameLb: UILabel!
    
    var selectedBankName: String = ""
    var recpId: String = ""
    let letters = NSCharacterSet.letters
    let allBankName = ["BNP Paribas (bnp)", "Bangkok Bank (bbl)", "Bank for Agriculture and Agricultural Cooperatives (baac)", "Bank of America (boa)", "Bank of Ayudhya Krungsri (bay)", "Bank of Tokyo-Mitsubishi UFJ (mufg)", "CIMB Thai Bank (cimb)", "Citibank (citi)", "Crédit Agricole (cacib)", "Deutsche Bank (db)", "Government Housing Bank (ghb)", "Government Savings Bank (gsb)", "Hongkong and Shanghai Banking Corporation (hsbc)", "Industrial and Commercial Bank of China (icbc)", "Islamic Bank of Thailand (ibank)", "J.P. Morgan (jpm)", "Kasikornbank (kbank)", "Kiatnakin Bank (kk)", "Krungthai Bank (ktb)", "Land and Houses Bank (lhb)", "Mega International Commercial Bank (mega)", "Mizuho Bank (mb)", "Royal Bank of Scotland (rbs)", "Siam Commercial Bank (scb)", "Standard Chartered (sc)", "Sumitomo Mitsui Banking Corporation (smbc)", "TMB Bank (tmb)", "Thai Credit Retail Bank (tcrb)", "Thanachart Bank (tbank)", "Tisco Bank (tisco)", "United Overseas Bank (uob)"]
    let allBankAbbreviation = ["bnp", "bbl", "baac", "boa", "bay", "mufg", "cimb", "citi", "cacib", "db", "ghb", "gsb", "hsbc", "icbc", "ibank", "jpm", "kbank", "kk", "ktb", "lhb", "mega", "mb", "rbs", "scb", "sc", "smbc", "tmb", "tcrb", "tbank", "tisco", "uob"]
    
    var ref: DatabaseReference!
    var currentUser: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ref = Database.database().reference()
        self.currentUser = Auth.auth().currentUser
        
        self.getOmiseCustId()
        
        self.confirmBtn.layer.cornerRadius = 5
        self.HideKeyboard()
        self.createPickerView()
        self.dismissPickerView()
    }
    
    func getOmiseCustId() {
        
        self.ref.child("user").child(self.currentUser.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let values = snapshot.value as? NSDictionary
            
            if values!["omise_cus_id"] as! String != "-1" {
                self.recpId = values!["omise_cus_id"] as! String
                self.getRecpData(self.recpId)
            } else {
                self.confirmBtn.addTarget(self, action: #selector(self.addRecpBtnAction), for: .touchUpInside)
            }
            
        }) { (err) in
            self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
            print(err.localizedDescription)
            return
        }
    }
    
    func getRecpData(_ omiseId: String) {
        
        let skey = String(format: "%@:", "skey_test_5dm3tm6pj69glowba1n").data(using: String.Encoding.utf8)!.base64EncodedString()
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        guard let URL = URL(string: "https://api.omise.co/recipients/\(omiseId)") else {return}
        
        var request = URLRequest(url: URL)
        
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("Basic \(String(describing: skey))", forHTTPHeaderField: "Authorization")
        
        let _ = session.dataTask(with: request) { (data, response, err) in
            
            DispatchQueue.main.async {
                if err == nil {
                    let statusCode = (response as! HTTPURLResponse).statusCode
                    print(statusCode)
                    
                    guard let data = data else {
                        print("no data")
                        return
                    }
                    
                    do {
                        let recpData = try JSONDecoder().decode(Recipient.self, from: data)
                        print(recpData)
                        self.setupDataToTextField(recpData: recpData)
                    } catch let jsonErr {
                        print("Err serializing json: ", jsonErr.localizedDescription)
                    }
                }
            }
            }.resume()
        session.finishTasksAndInvalidate()
    }
    
    @objc func addRecpBtnAction() {
        if checkEmptyData() {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            self.view.showBlurLoader()
            let skey = String(format: "%@:", "skey_test_5dm3tm6pj69glowba1n").data(using: String.Encoding.utf8)!.base64EncodedString()
            let sessionConfig = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
            guard let URL = URL(string: "https://api.omise.co/recipients") else {return}
            
            var request = URLRequest(url: URL)
            request.httpMethod = "POST"
            
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.addValue("Basic \(String(describing: skey))", forHTTPHeaderField: "Authorization")
            
            let params = "name=\(self.accountNameTf.text!)&type=individual&bank_account[name]=\(self.accountNameTf.text!)&bank_account[number]=\(self.accountNumberTf.text!)&bank_account[brand]=\(self.selectedBankName)"
            request.httpBody = params.data(using: .utf8, allowLossyConversion: true)
            
            let task = session.dataTask(with: request) { (data, response, err) in
                
                if err == nil {
                    let statusCode = (response as! HTTPURLResponse).statusCode
                    let jsonData = try! JSONSerialization.jsonObject(with: data!, options: []) as AnyObject
                    
                    if statusCode == 200 {
                        print(jsonData)
                        self.addOmiseRecpId(recpId: jsonData["id"] as! String)
                    } else if statusCode == 404 {
                        self.view.removeBluerLoader()
                        self.navigationController?.setNavigationBarHidden(false, animated: true)
                        print(jsonData["message"] as! String)
                        self.createAlert(alertTitle: jsonData["message"] as! String, alertMessage: "")
                    }
                } else {
                    self.view.removeBluerLoader()
                    self.navigationController?.setNavigationBarHidden(false, animated: true)
                    print(err?.localizedDescription)
                    self.createAlert(alertTitle: err!.localizedDescription, alertMessage: "")
                }
            }
            task.resume()
            session.finishTasksAndInvalidate()
        }
    }
    
    @objc func editRecpBtnAction() {
        if checkEmptyData() {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            self.view.showBlurLoader()
            let skey = String(format: "%@:", "skey_test_5dm3tm6pj69glowba1n").data(using: String.Encoding.utf8)!.base64EncodedString()
            let sessionConfig = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
            guard let URL = URL(string: "https://api.omise.co/recipients/\(self.recpId)") else {return}
            
            var request = URLRequest(url: URL)
            request.httpMethod = "PATCH"
            
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.addValue("Basic \(String(describing: skey))", forHTTPHeaderField: "Authorization")
            
            let params = "name=\(self.accountNameTf.text!)&bank_account[name]=\(self.accountNameTf.text!)&bank_account[number]=\(self.accountNumberTf.text!)"
            request.httpBody = params.data(using: .utf8, allowLossyConversion: true)
            
            let task = session.dataTask(with: request) { (data, response, err) in
                DispatchQueue.main.async {
                    if err == nil {
                        let statusCode = (response as! HTTPURLResponse).statusCode
                        let jsonData = try! JSONSerialization.jsonObject(with: data!, options: []) as AnyObject
                        
                        if statusCode == 200 {
                            print(jsonData)
                            self.view.removeBluerLoader()
                            self.navigationController?.setNavigationBarHidden(false, animated: true)
                            let alert = UIAlertController(title: "edit_bank_information_successful!_please_wait_for_approve".localized(), message: "", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: { (action) in
                                self.dismiss(animated: true, completion: nil)
                            }))
                            self.present(alert, animated: true, completion: nil)
                        } else if statusCode == 404 {
                            self.view.removeBluerLoader()
                            self.navigationController?.setNavigationBarHidden(false, animated: true)
                            print(jsonData["message"] as! String)
                            self.createAlert(alertTitle: jsonData["message"] as! String, alertMessage: "")
                        }
                    } else {
                        self.view.removeBluerLoader()
                        self.navigationController?.setNavigationBarHidden(false, animated: true)
                        print(err?.localizedDescription)
                        self.createAlert(alertTitle: err!.localizedDescription, alertMessage: "")
                    }
                }
            }
            task.resume()
            session.finishTasksAndInvalidate()
        } else {
            self.createAlert(alertTitle: "please_correct_your_bank_information".localized(), alertMessage: "")
        }
    }
    
    func addOmiseRecpId(recpId: String) {
        
        let recpData = ["omise_cus_id": recpId]
        ref.child("user").child(self.currentUser.uid).updateChildValues(recpData) { (err, ref) in
            if let err = err {
                self.view.removeBluerLoader()
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                print(err.localizedDescription)
                return
            }
            self.view.removeBluerLoader()
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            let alert = UIAlertController(title: "add_bank_information_successful_please_wait_for_approve".localized(), message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: { (action) in
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func setupDataToTextField(recpData: Recipient) {
        
        self.accountNameTf.text = recpData.bankAccount.name
        self.accountNumberTf.text = "xxxxxx\(recpData.bankAccount.lastDigits)"
        self.bankNameTf.text = self.allBankName[self.allBankAbbreviation.firstIndex(of: recpData.bankAccount.brand)!]
        self.accountNameTf.attributedPlaceholder = NSAttributedString(string: "account_name".localized(), attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        self.accountNumberTf.attributedPlaceholder = NSAttributedString(string: "account_number".localized(), attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        self.bankNameTf.attributedPlaceholder = NSAttributedString(string: "bank_name".localized(), attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        if recpData.verified! {
            self.bankNameTf.isEnabled = false
            self.confirmBtn.setTitle("edit".localized(), for: .normal)
            self.confirmBtn.addTarget(self, action: #selector(self.editRecpBtnAction), for: .touchUpInside)
        } else {
            self.accountNameTf.isEnabled = false
            self.accountNumberTf.isEnabled = false
            self.bankNameTf.isEnabled = false
            self.confirmBtn.isEnabled = false
            self.confirmBtn.backgroundColor = UIColor.gray
            self.confirmBtn.setTitle("wait_for_approve".localized(), for: .normal)
        }
    }
    
    func createPickerView() {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        self.bankNameTf.inputView = pickerView
    }
    
    func dismissPickerView() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "done".localized(), style: .plain, target: self, action: #selector(self.dissmissKeyboard))
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        self.bankNameTf.inputAccessoryView = toolBar
    }
    
    @objc func dissmissKeyboard() {
        
        view.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.allBankName.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.allBankName[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedBankName = self.allBankAbbreviation[row]
        self.bankNameTf.text = self.allBankName[row]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        self.setupNavigationStyle()
        
        self.title = "bank_account".localized()
        
        self.accountNameLb.text = "account_name".localized()
        self.accountNumberLb.text  = "account_number".localized()
        self.bankNameLb.text = "bank_name".localized()
        
        self.confirmBtn.setTitle("confirm".localized(), for: .normal)
        
        self.accountNameTf.attributedPlaceholder = NSAttributedString(string: "loading ...".localized(), attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        self.accountNumberTf.attributedPlaceholder = NSAttributedString(string: "loading ...".localized(), attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        self.bankNameTf.attributedPlaceholder = NSAttributedString(string: "loading ...".localized(), attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
    }
    
    func checkEmptyData() -> Bool {
        
        if self.accountNameTf.text == "" || self.accountNumberTf.text == "" || self.bankNameTf.text == "" {
            return false
        } else if self.accountNameTf.text!.containsEmoji {
            return false
        } else if self.accountNumberTf.text!.containsEmoji {
            return false
        }
        return true
    }
    
    @IBAction func cancelBtnAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}
