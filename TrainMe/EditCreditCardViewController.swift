//
//  EditCreditCardViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 1/12/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import Foundation
import UIKit
import DTTextField

class EditCreditCardViewController: UIViewController {

    @IBOutlet weak var cardHolderLb: DTTextField!
    @IBOutlet weak var cardExpiryLb: DTTextField!
    @IBOutlet weak var editCardBtn: UIButton!
    
    var selectedCardData: CardData! = nil
    var omiseCustId: String!
    let date = Date()
    let calendar = Calendar.current
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(self.selectedCardData)
        
        editCardBtn.layer.cornerRadius = 17
        
        self.cardExpiryLb.addTarget(self, action: #selector(self.expiryMonthCheckActionSelector), for: .editingChanged)
        self.cardHolderLb.text = self.selectedCardData.name
        self.cardExpiryLb.text = "\(self.selectedCardData.expirationMonth)/\(self.selectedCardData.expirationYear)"
    }
    
    @IBAction func editCreditCardAction(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Confirm to change card data", message: "Card holder: \(self.cardHolderLb.text!)\n Card expiration: \(self.cardExpiryLb.text!)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (yesAction) in
            
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            self.view.showBlurLoader()
            
            self.expiryMonthCheckActionBtn()
            
            let currentYear = self.calendar.component(.year, from: self.date) - 543
            let currentMonth = self.calendar.component(.month, from: self.date)

            if self.checkCardHolder(name: self.cardHolderLb.text!) {
                if self.checkRegex(expiry: self.cardExpiryLb.text!) {
                    let checkExpiry_ = self.checkExpiry(currentYear: currentYear,
                                                        currentMonth: currentMonth,
                                                        expiryYear: Int((self.cardExpiryLb.text?.components(separatedBy: "/")[1])!)!,
                                                        expiryMonth: Int((self.cardExpiryLb.text?.components(separatedBy: "/")[0])!)!)
                    if checkExpiry_ {
                        print("All new data pass")
                        self.changeCardData(expiryYear: (self.cardExpiryLb.text?.components(separatedBy: "/")[1])!,
                                            expiryMonth: (self.cardExpiryLb.text?.components(separatedBy: "/")[0])!,
                                            name: self.cardHolderLb.text!)
                    } else {
                        self.view.removeBluerLoader()
                        self.navigationController?.setNavigationBarHidden(false, animated: true)
                        self.createAlert(alertTitle: "Invalid expire", alertMessage: "")
                    }
                } else {
                    self.view.removeBluerLoader()
                    self.navigationController?.setNavigationBarHidden(false, animated: true)
                    self.createAlert(alertTitle: "Invalid expire", alertMessage: "")
                }
            } else {
                self.view.removeBluerLoader()
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                self.createAlert(alertTitle: "Invalid card holder", alertMessage: "")
            }
        }))
        alert.addAction(UIAlertAction(title: "No", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func checkExpiry(currentYear: Int, currentMonth: Int, expiryYear: Int, expiryMonth: Int) -> Bool {
        
        if (expiryYear < currentYear) {
            return false
        }
        if (expiryYear == currentYear && expiryMonth < currentMonth) {
            return false
        }
        if (expiryYear > currentYear+15) {
            return false
        }
        if(expiryYear >= currentYear+15 && expiryMonth > currentMonth){
            return false
        }
        return true
    }
    
    func checkRegex(expiry: String) -> Bool {
        
        let re = "(0[1-9]|10|11|12)/20[0-9]{2}$"
        return expiry.range(of: re, options: .regularExpression, range: nil, locale: nil) != nil
    }
    
    func checkCardHolder(name: String) -> Bool { return name != "" }
    
    @objc func expiryMonthCheckActionSelector() {
        
        let expiry = cardExpiryLb.text!.components(separatedBy: "/")
        let monthRange = ["2", "3", "4", "5", "6", "7", "8", "9"]
        
        print(expiry)
        
        if monthRange.contains(expiry[0]) && expiry.count > 1 {
            cardExpiryLb.text = "0\(expiry[0])/\(expiry[1])"
        }
    }
    
    func expiryMonthCheckActionBtn() {
        
        let expiry = cardExpiryLb.text!.components(separatedBy: "/")
        let monthRange = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
        
        print(expiry)
        
        if expiry.count != 2 || expiry[0] == "" || expiry[1] == "" {
            self.view.removeBluerLoader()
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.createAlert(alertTitle: "Invalid expire", alertMessage: "Expire format must be in mm/YYYY\nEx. 05/2018")
            return
        }
        if monthRange.contains(expiry[0]) {
            cardExpiryLb.text = "0\(expiry[0])/\(expiry[1])"
        }
    }
    
    func changeCardData(expiryYear: String, expiryMonth: String, name: String) {

        //TODO: change card holder
        let skey = String(format: "%@:", "skey_test_5dm3tm6pj69glowba1n").data(using: String.Encoding.utf8)!.base64EncodedString()
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        guard let URL = URL(string: "https://api.omise.co/customers/\(self.omiseCustId!)/cards/\(self.selectedCardData.id)") else { return }
        
        var request = URLRequest(url: URL)
        
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("Basic \(String(describing: skey))", forHTTPHeaderField: "Authorization")
        request.httpMethod = "PATCH"
        
        let params = "expiration_month=\(expiryMonth)&expiration_year=\(expiryYear)"
        request.httpBody = params.data(using: .utf8, allowLossyConversion: true)
        
        let _ = session.dataTask(with: request) { (data, response, err) in
            
            DispatchQueue.main.async {
                if err == nil {
                    let statusCode = (response as! HTTPURLResponse).statusCode
                    if statusCode == 200 {
                        let jsonData = try! JSONSerialization.jsonObject(with: data!, options: []) as AnyObject
                        if jsonData["object"] as! String == "card" {
                            self.view.removeBluerLoader()
                            self.navigationController?.setNavigationBarHidden(false, animated: true)
                            let alert = UIAlertController(title: "Successful change card information", message: "", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (okAction) in
                                self.dismiss(animated: true, completion: nil)
                            }))
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            self.view.removeBluerLoader()
                            self.navigationController?.setNavigationBarHidden(false, animated: true)
                            self.createAlert(alertTitle: "Error change card information", alertMessage: "")
                        }
                    } else {
                        self.view.removeBluerLoader()
                        self.navigationController?.setNavigationBarHidden(false, animated: true)
                        self.createAlert(alertTitle: "Error change card information", alertMessage: "")
                    }
                } else {
                    self.view.removeBluerLoader()
                    self.navigationController?.setNavigationBarHidden(false, animated: true)
                    self.createAlert(alertTitle: err!.localizedDescription, alertMessage: "")
                }
            }
            }.resume()
        session.finishTasksAndInvalidate()
    }
    
    @IBAction func cancelBtnAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupNavigationStyle()
    }

}
