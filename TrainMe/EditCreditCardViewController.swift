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
    
    var selectedCardData: CardData! = nil
    let date = Date()
    let calendar = Calendar.current
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(self.selectedCardData)
        
        self.cardExpiryLb.addTarget(self, action: #selector(self.expiryMonthCheckActionSelector), for: .editingChanged)
        self.cardHolderLb.text = self.selectedCardData.name
        self.cardExpiryLb.text = "\(self.selectedCardData.expirationMonth)/\(self.selectedCardData.expirationYear)"
    }
    
    @IBAction func editCreditCardAction(_ sender: UIButton) {
        
        self.expiryMonthCheckActionBtn()
        
        let alert = UIAlertController(title: "Confirm to change card data", message: "Card holder: \(self.cardHolderLb.text!)\n Card expiration: \(self.cardExpiryLb.text!)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (yesAction) in
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
                        self.changeCardData()
                    } else {
                        self.createAlert(alertTitle: "Invalid expire", alertMessage: "")
                    }
                } else {
                    self.createAlert(alertTitle: "Invalid expire", alertMessage: "")
                }
            } else {
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
            self.createAlert(alertTitle: "Invalid expire", alertMessage: "Expire format must be in mm/YYYY\nEx. 05/2018")
            return
        }
        if monthRange.contains(expiry[0]) {
            cardExpiryLb.text = "0\(expiry[0])/\(expiry[1])"
        }
    }
    
    func changeCardData() {
        
        //TODO: Change omise card data
    }
    
    @IBAction func cancelBtnAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupNavigationStyle()
    }

}
