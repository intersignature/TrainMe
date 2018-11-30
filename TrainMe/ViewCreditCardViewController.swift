//
//  ViewCreditCardViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 28/11/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ViewCreditCardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var creditCardTableView: UITableView!
    var ref = Database.database().reference()
    var currentUser = Auth.auth().currentUser

    var allData: CreditCard!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.creditCardTableView.delegate = self
        self.creditCardTableView.dataSource = self
    }
    
    func getOmiseCustId() {
        
        ref.child("user").child(currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let value = snapshot.value as! NSDictionary
            print(value["omise_cus_id"] as! String)
            self.getCustInfo(omiseCustId: value["omise_cus_id"] as! String)
        }) { (err) in
            print(err.localizedDescription)
            self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
            return
        }
    }
    
    func getCustInfo(omiseCustId: String) {
        
        let skey = String(format: "%@:", "skey_test_5dm3tm6pj69glowba1n").data(using: String.Encoding.utf8)!.base64EncodedString()
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        guard let URL = URL(string: "https://api.omise.co/customers/\(omiseCustId)") else {return}
        
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
                        self.allData = try JSONDecoder().decode(CreditCard.self, from: data)
                        self.allData.cards.data.forEach({ (eachData) in
                            print(eachData.lastDigits)
                        })
                        self.creditCardTableView.reloadData()
                    } catch let jsonErr {
                        print("Err serializing json: ", jsonErr.localizedDescription)
                    }
                    
                }
            }
        }.resume()
        session.finishTasksAndInvalidate()
    }
    
    func deleteOmiseCard(deleteCardIndexPath: IndexPath) {
        
        let skey = String(format: "%@:", "skey_test_5dm3tm6pj69glowba1n").data(using: String.Encoding.utf8)!.base64EncodedString()
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        guard let URL = URL(string: "https://api.omise.co/customers/\(self.allData.id)/cards/\(self.allData.cards.data[deleteCardIndexPath.row].id)") else {return}
        
        var request = URLRequest(url: URL)
        
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("Basic \(String(describing: skey))", forHTTPHeaderField: "Authorization")
        request.httpMethod = "DELETE"
        
        let _ = session.dataTask(with: request) { (data, response, err) in
            
            DispatchQueue.main.async {
                if err == nil {
                    let statusCode = (response as! HTTPURLResponse).statusCode
                    print(statusCode)
                    
                    guard let data = data else {
                        print("no data")
                        return
                    }
                    
                    if statusCode == 200 {
                        let jsonData = try! JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                        if jsonData["object"] as! String == "card" {
                            self.createAlert(alertTitle: "Delete credit card successful", alertMessage: "")
                        } else if jsonData["object"] as! String == "error"{
                            self.createAlert(alertTitle: "Failed to delete credit card", alertMessage: "")
                        }
                    }
                }
            }
            }.resume()
        session.finishTasksAndInvalidate()
    }
    
    func deleteCardFromData(deleteDataIndexPath: IndexPath) {
        
        self.allData.cards.data.remove(at: deleteDataIndexPath.row)
    }
    
    @IBAction func backBtnAction(_ sender: UIBarButtonItem) {

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.allData == nil {
            return 0
        } else {
            print("table view cell count: \(self.allData.cards.data.count)")
            return self.allData.cards.data.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ViewCreditCardTableViewCell") as! ViewCreditCardTableViewCell
        cell.setDataToCell(name: self.allData.cards.data[indexPath.row].name,
                           bank: self.allData.cards.data[indexPath.row].bank,
                           last4digits: self.allData.cards.data[indexPath.row].lastDigits,
                           brand: self.allData.cards.data[indexPath.row].brand)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (deleteRowAction, deleteRowIndexPath) in
            print(deleteRowIndexPath)
            
            let alert = UIAlertController(title: "", message: "Would you like to delete this credit card?", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action1) in
                self.deleteOmiseCard(deleteCardIndexPath: deleteRowIndexPath)
                self.deleteCardFromData(deleteDataIndexPath: deleteRowIndexPath)
                tableView.beginUpdates()
                tableView.deleteRows(at: [deleteRowIndexPath], with: .automatic)
                tableView.endUpdates()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (editRowAction, editRowIndexPath) in
            print(editRowIndexPath)
            self.performSegue(withIdentifier: "ViewCreditCardToEditCreditCard", sender: editRowIndexPath)
        }
        return [editAction, deleteAction]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewCreditCardToEditCreditCard" {
            let vc = segue.destination as! UINavigationController
            let containVc = vc.topViewController as! EditCreditCardViewController
            
            guard let selectedEditRowIndexPath = sender as? IndexPath else {
                print("selectedEditRowIndexPath is not an IndexPath")
                return
            }
            print("selectedEditRowIndexPath: \(selectedEditRowIndexPath)")
            
            containVc.selectedCardData = self.allData.cards.data[selectedEditRowIndexPath.row]
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupNavigationStyle()
        getOmiseCustId()
    }
}
