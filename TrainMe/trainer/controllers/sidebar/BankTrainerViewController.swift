//
//  BankTrainerViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 15/1/2562 BE.
//  Copyright © 2562 Sirichai Binchai. All rights reserved.
//

import UIKit
import DTTextField

class BankTrainerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var accountNameTf: DTTextField!
    @IBOutlet weak var accountNumberTf: DTTextField!
    @IBOutlet weak var bankNameTf: DTTextField!
    @IBOutlet weak var confirmBtn: UIButton!
    
    var selectedBankName: String = ""
    let letters = NSCharacterSet.letters
    let allBankName = ["BNP Paribas (bnp)", "Bangkok Bank (bbl)", "Bank for Agriculture and Agricultural Cooperatives (baac)", "Bank of America (boa)", "Bank of Ayudhya Krungsri (bay)", "Bank of Tokyo-Mitsubishi UFJ (mufg)", "CIMB Thai Bank (cimb)", "Citibank (citi)", "Crédit Agricole (cacib)", "Deutsche Bank (db)", "Government Housing Bank (ghb)", "Government Savings Bank (gsb)", "Hongkong and Shanghai Banking Corporation (hsbc)", "Industrial and Commercial Bank of China (icbc)", "Islamic Bank of Thailand (ibank)", "J.P. Morgan (jpm)", "Kasikornbank (kbank)", "Kiatnakin Bank (kk)", "Krungthai Bank (ktb)", "Land and Houses Bank (lhb)", "Mega International Commercial Bank (mega)", "Mizuho Bank (mb)", "Royal Bank of Scotland (rbs)", "Siam Commercial Bank (scb)", "Standard Chartered (sc)", "Sumitomo Mitsui Banking Corporation (smbc)", "TMB Bank (tmb)", "Thai Credit Retail Bank (tcrb)", "Thanachart Bank (tbank)", "Tisco Bank (tisco)", "United Overseas Bank (uob)"]
    let allBankAbbreviation = ["bnp", "bbl", "baac", "boa", "bay", "mufg", "cimb", "citi", "cacib", "db", "ghb", "gsb", "hsbc", "icbc", "ibank", "jpm", "kbank", "kk", "ktb", "lhb", "mega", "mb", "rbs", "scb", "sc", "smbc", "tmb", "tcrb", "tbank", "tisco", "uob"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.confirmBtn.layer.cornerRadius = 5
        self.HideKeyboard()
        self.createPickerView()
        self.dismissPickerView()
    }
    
    func createPickerView() {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        self.bankNameTf.inputView = pickerView
    }
    
    func dismissPickerView() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.dissmissKeyboard))
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
        
        self.setupNavigationStyle()
    }
    
    @IBAction func confirmBtnAction(_ sender: UIButton) {
        
        if checkEmptyData() {
            // change bank detail
            print(self.checkEmptyData())
        } else {
            self.createAlert(alertTitle: "Please correct your bank information", alertMessage: "")
        }
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
