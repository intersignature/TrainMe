//
//  SelectCreditCardToChargeViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 29/11/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class SelectCreditCardToChargeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var creditCardTableView: UITableView!
    var selectedCourse: Course!
    var pendingData: PendingBookPlaceDetail!
    
    var ref = Database.database().reference()
    var currentUser = Auth.auth().currentUser
    
    var allData: CreditCard!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.creditCardTableView.delegate = self
        self.creditCardTableView.dataSource = self

        print(selectedCourse)
        print(pendingData.getData())
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
                    
                    if statusCode == 200 {
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
            }
        }.resume()
        session.finishTasksAndInvalidate()
    }
    
    func chargeWithCusAndPrice(selectedIndexPath: IndexPath) {
        
        let calculatedCoursePrice = Int(Double(self.selectedCourse.coursePrice)!*0.75)*100
        let skey = String(format: "%@:", "skey_test_5dm3tm6pj69glowba1n").data(using: String.Encoding.utf8)!.base64EncodedString()
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        guard let URL = URL(string: "https://api.omise.co/charges") else { return }
        
        var request = URLRequest(url: URL)
        
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("Basic \(String(describing: skey))", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        
        let params = "amount=\(calculatedCoursePrice)&currency=thb&customer=\(self.allData.id)&card=\(self.allData.cards.data[selectedIndexPath.row].id)"
        request.httpBody = params.data(using: .utf8, allowLossyConversion: true)
        
        let _ = session.dataTask(with: request) { (data, response, err) in
            
            DispatchQueue.main.async {
                if err == nil {
                    let statusCode = (response as! HTTPURLResponse).statusCode
                    if statusCode == 200 {
                        let jsonData = try! JSONSerialization.jsonObject(with: data!, options: []) as AnyObject
                        if jsonData["status"] as! String == "successful" {
                            self.addProgressData(transactionId: jsonData["id"] as! String)
                        } else if jsonData["status"] as! String == "failed" {
                            print(jsonData["status"] as! String)
                            self.navigationController?.setNavigationBarHidden(false, animated: true)
                            self.view.removeBluerLoader()
                            self.createAlert(alertTitle: (jsonData["failure_code"] as! String), alertMessage: (jsonData["failure_message"] as! String))
                        }
                    } else {
                        self.navigationController?.setNavigationBarHidden(false, animated: true)
                        self.view.removeBluerLoader()
                        self.createAlert(alertTitle: "error_request".localized(), alertMessage: "")
                    }
                    
                    print("status code: \(statusCode)")
                    
                }
            }
        }.resume()
        session.finishTasksAndInvalidate()
    }
    
    func addProgressData(transactionId: String) {
        print("transactionId: \(transactionId)")
        
        var mainData: [String: Any] = ["course_id": pendingData.course_id,
                        "place_id": pendingData.place_id,
                        "transaction_to_admin": transactionId,
                        "transaction_to_trainer": "-1"]
        
        for i in 1...Int(self.selectedCourse.timeOfCourse)! {
            
            if i == 1 {
                
                let timeSchedule = ["start_train_date": pendingData.start_train_date,
                                    "start_train_time": pendingData.start_train_time,
                                    "status": "1",
                                    "is_trainee_confirm": "-1",
                                    "is_trainer_confirm": "-1",
                                    "rate_point": "-1",
                                    "review": "-1",
                                    "note": "-1"]
                mainData["\(i)"] = timeSchedule
            } else {
                
                let timeSchedule = ["start_train_date": "-1",
                                    "start_train_time": "-1",
                                    "status": "-1",
                                    "is_trainee_confirm": "-1",
                                    "is_trainer_confirm": "-1",
                                    "rate_point": "-1",
                                    "review": "-1",
                                    "note": "-1"]
                mainData["\(i)"] = timeSchedule
            }
        }
        
        self.ref.child("progress_schedule_detail").child(pendingData.trainer_id).child(pendingData.trainee_id).child(pendingData.schedule_key).setValue(mainData) { (err, progressRef) in
            if let err = err {
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                self.view.removeBluerLoader()
                print(err.localizedDescription)
                self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                return
            } else {
              self.deletePendingData()
                
                // delete code below when uncomment deletePendingData() call method
//                self.navigationController?.setNavigationBarHidden(false, animated: true)
//                self.view.removeBluerLoader()
//                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func deletePendingData() {
        
        self.ref.child("pending_schedule_detail").child(pendingData.trainer_id).child(pendingData.schedule_key).removeValue { (err, ref) in
            
            if let err = err {
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                self.view.removeBluerLoader()
                print(err.localizedDescription)
                self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                return
            }
            self.addNotificationDatabase(toUid: self.pendingData.trainer_id, description: "Your trainee was pay for train course successfully, Please check it out")
        }
    }
    
    @IBAction func cancelBtnAction(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectCreditCardTableViewCell") as! ViewCreditCardTableViewCell
        cell.setDataToCell(name: self.allData.cards.data[indexPath.row].name,
                           bank: self.allData.cards.data[indexPath.row].bank,
                           last4digits: self.allData.cards.data[indexPath.row].lastDigits,
                           brand: self.allData.cards.data[indexPath.row].brand)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let alert = UIAlertController(title: "confirm_to_pay".localized(), message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "confirm".localized(), style: .default, handler: { (action) in
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            self.view.showBlurLoader()
            self.chargeWithCusAndPrice(selectedIndexPath: indexPath)
        }))
        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        self.setupNavigationStyle()
        
        self.title = "select_your_credit_card".localized()
        
        self.creditCardTableView.tableFooterView = UIView()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        getOmiseCustId()
    }
    
    func addNotificationDatabase(toUid: String, description: String) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        dateFormatter.locale = Locale(identifier: "en")
        let currentStringOfDate = dateFormatter.string(from: Date())
        
        let notificationData = ["from_uid": self.currentUser!.uid,
                                "description": description,
                                "timestamp": currentStringOfDate,
                                "is_read": "0"]
        
        self.ref.child("notifications").child(toUid).childByAutoId().updateChildValues(notificationData) { (err, ref) in
            if let err = err {
                self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                print(err.localizedDescription)
                return
            }
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.view.removeBluerLoader()
            let alert = UIAlertController(title: "your_payment_successful".localized(), message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: { (action) in
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
