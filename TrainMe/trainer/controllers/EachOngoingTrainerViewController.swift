//
//  EachOngoingTrainerViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 19/12/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class EachOngoingTrainerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
   
    @IBOutlet weak var eachOngoingTrainerTableView: UITableView!
    
    var newScheduleDate: UITextField!
    var newScheduleTime: UITextField!
    
    var selectedTrainerUid: String!
    var selectedTraineeUid: String!
    var selectedOngoingId: String!
    var coursePrice: String!
    
    var selectedOngoing: OngoingDetail!
    var ref: DatabaseReference!
    var currentUser: User!
    
    var datePicker: UIDatePicker!
    var timePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("selectedOngoingzz: \(selectedOngoing)")
        
        self.selectedOngoing = OngoingDetail()
        self.ref = Database.database().reference()
        self.currentUser = Auth.auth().currentUser
        
        self.getEachOngoing()
        
        self.eachOngoingTrainerTableView.dataSource = self
        self.eachOngoingTrainerTableView.delegate = self
    }
    
    func getEachOngoing() {
        
        self.ref.child("progress_schedule_detail").child(self.selectedTrainerUid).child(self.selectedTraineeUid).child(self.selectedOngoingId).observe(.value, with: { (snapshot) in
            let value = snapshot.value as? AnyObject
            print(value!.count)
            var tempEachOngoings: [EachOngoingDetail] = []
            for i in 1...(Int(value!.count)-4){
                print("courseId: \(i)")
                let eachDetailValue = value![String(i)] as? NSDictionary
                let tempEachOngoing = EachOngoingDetail(start_train_date: eachDetailValue!["start_train_date"] as! String,
                                                        start_train_time: eachDetailValue!["start_train_time"] as! String,
                                                        status: eachDetailValue!["status"] as! String,
                                                        count: "\(i)",
                    is_trainee_confirm: eachDetailValue!["is_trainee_confirm"] as! String,
                    is_trainer_confirm: eachDetailValue!["is_trainer_confirm"] as! String,
                    note: eachDetailValue!["note"] as! String,
                    rate_point: eachDetailValue!["rate_point"] as! String,
                    review: eachDetailValue!["review"] as! String)
                tempEachOngoings.append(tempEachOngoing)
            }
            
            var tempOngoingDetail = OngoingDetail(ongoingId: self.selectedOngoingId,
                                                  traineeId: self.selectedTraineeUid,
                                                  courseId: value!["course_id"] as! String,
                                                  placeId: value!["place_id"] as! String,
                                                  transactionToAdmin: value!["transaction_to_admin"] as! String,
                                                  transactionToTrainer: value!["transaction_to_trainer"] as! String,
                                                  eachOngoingDetails: tempEachOngoings)
            tempOngoingDetail.trainerId = self.selectedTrainerUid
            self.selectedOngoing = tempOngoingDetail
            self.eachOngoingTrainerTableView.reloadData()
        }) { (err) in
            self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
            print(err.localizedDescription)
            return
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.selectedOngoing.eachOngoingDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "EachOngoingTrainerTableViewCell") as! EachOngoingTrainerTableViewCell
        cell.countLb.text = self.selectedOngoing.eachOngoingDetails[indexPath.row].count
        cell.dateAndTimeScheduleLb.text = "\(self.selectedOngoing.eachOngoingDetails[indexPath.row].start_train_date) \(self.selectedOngoing.eachOngoingDetails[indexPath.row].start_train_time)"
        cell.changeScheduleBtn.tag = indexPath.row
        cell.changeScheduleBtn.addTarget(self, action: #selector(self.changeScheduleBtnAction(sender:)), for: .touchUpInside)
        cell.confirmSuccessTrainBtn.tag = indexPath.row
        cell.confirmSuccessTrainBtn.addTarget(self, action: #selector(self.confirmBtnAction(sender:)), for: .touchUpInside)
        
        if self.selectedOngoing.eachOngoingDetails[indexPath.row].status == "-1" {
            cell.changeScheduleBtn.isEnabled = false
            cell.confirmSuccessTrainBtn.isEnabled = false
            cell.statusLb.text = "Pending"
        } else if self.selectedOngoing.eachOngoingDetails[indexPath.row].status == "1" {
            cell.changeScheduleBtn.isEnabled = true
            cell.confirmSuccessTrainBtn.isEnabled = true
            if self.selectedOngoing.eachOngoingDetails[indexPath.row].is_trainer_confirm == "1" && self.selectedOngoing.eachOngoingDetails[indexPath.row].is_trainee_confirm == "-1" {
                cell.changeScheduleBtn.isEnabled = false
                cell.confirmSuccessTrainBtn.isEnabled = false
            } else if self.selectedOngoing.eachOngoingDetails[indexPath.row].is_trainer_confirm == "-1" && self.selectedOngoing.eachOngoingDetails[indexPath.row].is_trainee_confirm == "1" {
                cell.changeScheduleBtn.isEnabled = false
            }
            cell.statusLb.text = "Ongoing"
        } else if self.selectedOngoing.eachOngoingDetails[indexPath.row].status == "2" {
            cell.changeScheduleBtn.isEnabled = false
            cell.confirmSuccessTrainBtn.isEnabled = false
            cell.statusLb.text = "Successful"
        } else if self.selectedOngoing.eachOngoingDetails[indexPath.row].status == "3" {
            cell.changeScheduleBtn.isEnabled = true
            cell.confirmSuccessTrainBtn.isEnabled = false
            cell.statusLb.text = "Change schedule requested"
        }
        return cell
    }
    
    @objc func changeScheduleBtnAction(sender: UIButton) {
        
        //TODO: changeSchedule
        print("changeSchedule: \(sender.tag)")
        let alert = UIAlertController(title: "Change schedule date", message: "", preferredStyle: .alert)
        alert.addTextField(configurationHandler: newScheduleDate)
        alert.addTextField(configurationHandler: newScheduleTime)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in

            if self.checkNewSchedule() {
                self.view.showBlurLoader()
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                self.changeSchdedule(sender: sender)
            } else {
                self.createAlert(alertTitle: "Plaese enter new schedule date and tiim", alertMessage: "")
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func newScheduleDate(textField: UITextField) {
        
        self.newScheduleDate = textField
        self.setupDatePicker()
        self.newScheduleDate?.textAlignment = .center
        self.newScheduleDate?.placeholder = "Change schedule date"
    }
    
    func newScheduleTime(textField: UITextField) {
        
        self.newScheduleTime = textField
        self.setupTimePicker()
        self.newScheduleTime?.textAlignment = .center
        self.newScheduleTime?.placeholder = "Change schedule time"
    }
    
    func setupDatePicker() {
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateChange(datePicker:)), for: .valueChanged)
        
        self.newScheduleDate!.inputView = datePicker
    }
    
    func setupTimePicker() {
        timePicker = UIDatePicker()
        timePicker.datePickerMode = .time
        timePicker.addTarget(self, action: #selector(timeChange(datePicker:)), for: .valueChanged)
        
        self.newScheduleTime!.inputView = timePicker
    }
    
    
    @objc func dateChange(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en")
        dateFormatter.setLocalizedDateFormatFromTemplate("dd/MM/yyyy")
        
        let tempDate = dateFormatter.string(from: datePicker.date).split(separator: "/")
        self.newScheduleDate!.text = "\(tempDate[1])/\(tempDate[0])/\(tempDate[2])"
    }
    
    @objc func timeChange(datePicker: UIDatePicker) {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        self.newScheduleTime!.text = timeFormatter.string(from: timePicker.date)
    }
    
    func checkNewSchedule() -> Bool {
        print("checkNewSchedule \(self.newScheduleDate?.text != "") \(self.newScheduleTime?.text != "")")
        return self.newScheduleDate?.text != "" && self.newScheduleTime?.text != ""
    }
    
    func changeSchdedule(sender: UIButton) {

        guard let newDate = newScheduleDate.text else {
            return
        }
        
        guard let newTime = newScheduleTime.text else {
            return
        }
        
        let changeScheduleData = ["start_train_date": newDate,
                                  "start_train_time": newTime,
                                  "status": "1"]
        self.ref.child("progress_schedule_detail").child(self.currentUser.uid).child(self.selectedOngoing.traineeId).child(self.selectedOngoing.ongoingId).child(self.selectedOngoing.eachOngoingDetails[sender.tag].count).updateChildValues(changeScheduleData) { (err, ref) in
            
            if let err = err {
                self.view.removeBluerLoader()
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                print(err.localizedDescription)
                self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                return
            }
            
            self.eachOngoingTrainerTableView.reloadData()
            self.addNotificationDatabase(toUid: self.selectedOngoing.traineeId, description: "Your trainer was change schedule date. Please check your new schedule.", from: "change schedule")
        }
    }

    @objc func confirmBtnAction(sender: UIButton) {
        
        let alert = UIAlertController(title: "Are you sure to confirm training?", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
//            self.confirmSuccessStatusToDatabase(sender: sender)
            self.view.showBlurLoader()
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            self.checkTraineeIsConfirm(sender: sender)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func checkTraineeIsConfirm(sender: UIButton) {
        
        self.ref.child("progress_schedule_detail").child(self.currentUser.uid).child(self.selectedOngoing.traineeId).child(self.selectedOngoing.ongoingId).child(self.selectedOngoing.eachOngoingDetails[sender.tag].count).child("is_trainee_confirm").observeSingleEvent(of: .value, with: { (snapshot) in
            let isTraineeConfirm = snapshot.value as! String
            self.confirmSuccessStatusToDatabase(isTraineeConfirm: isTraineeConfirm, sender: sender)
        }) { (err) in
            self.view.removeBluerLoader()
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
            return
        }
    }
    
    func confirmSuccessStatusToDatabase(isTraineeConfirm: String, sender: UIButton) {
        
        var confirmData = ["is_trainer_confirm": "1"]
        
        if isTraineeConfirm == "1" {
            confirmData = ["is_trainer_confirm": "1",
                           "status": "2"]
        }
        
        self.ref.child("progress_schedule_detail").child(self.currentUser.uid).child(self.selectedOngoing.traineeId).child(self.selectedOngoing.ongoingId).child(self.selectedOngoing.eachOngoingDetails[sender.tag].count).updateChildValues(confirmData) { (err, ref) in
            
            if let err = err {
                self.view.removeBluerLoader()
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                print(err.localizedDescription)
                self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                return
            }

            if isTraineeConfirm == "1" {
                if self.selectedOngoing.eachOngoingDetails.count > Int(self.selectedOngoing.eachOngoingDetails[sender.tag].count)! {
                    self.setStatusToNextSchedule(sender: sender)
                } else {
                    self.getRecpId()
                }
            } else {
                self.eachOngoingTrainerTableView.reloadData()
                self.addNotificationDatabase(toUid: self.selectedOngoing.traineeId, description: "Your trainer was confirmed training session already waiting for your review", from: "wait review")
            }
        }
        print("confirmSuccessStatusToDatabase: \(sender.tag)")
    }
    
    func getRecpId() {
        
        self.ref.child("user").child(self.currentUser.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let value = snapshot.value as! NSDictionary
            self.transferMoney(recpId: value["omise_cus_id"] as! String)
        }) { (err) in
            self.view.removeBluerLoader()
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
            print(err.localizedDescription)
            return
        }
    }
    
    func transferMoney(recpId: String) {
        let skey = String(format: "%@:", "skey_test_5dm3tm6pj69glowba1n").data(using: String.Encoding.utf8)!.base64EncodedString()
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        guard let URL = URL(string: "https://api.omise.co/transfers") else {return}
        
        var request = URLRequest(url: URL)
        request.httpMethod = "POST"
        
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("Basic \(String(describing: skey))", forHTTPHeaderField: "Authorization")
        
        let params = "amount=\(Int(self.coursePrice)!*100)&recipient=\(recpId)"
        request.httpBody = params.data(using: .utf8, allowLossyConversion: true)
        
        let task = session.dataTask(with: request) { (data, response, err) in
            DispatchQueue.main.async {
                if err == nil {
                    let statusCode = (response as! HTTPURLResponse).statusCode
                    let jsonData = try! JSONSerialization.jsonObject(with: data!, options: []) as AnyObject
                    
                    if statusCode == 200 {
                        print(jsonData["id"] as! String)
                        self.addTransactionId(transactionId: jsonData["id"] as! String)
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
    }
    
    func addTransactionId(transactionId: String) {
        
        let transactionData = ["transaction_to_trainer": transactionId]
        
        self.ref.child("progress_schedule_detail").child(self.currentUser.uid).child(self.selectedTraineeUid).child(self.selectedOngoingId).updateChildValues(transactionData) { (err, ref) in
            if let err = err {
                self.view.removeBluerLoader()
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                print(err.localizedDescription)
                return
            }
            self.eachOngoingTrainerTableView.reloadData()
            self.addNotificationDatabase(toUid: self.selectedOngoing.traineeId, description: "Your trainer was confirmed training session and pay money to your trainer account already", from: "transfer money")
        }
    }
    
    func setStatusToNextSchedule(sender: UIButton) {
        
        let statusNextScheduleData = ["status": "1"]
        self.ref.child("progress_schedule_detail").child(self.currentUser.uid).child(self.selectedOngoing.traineeId).child(self.selectedOngoing.ongoingId).child(self.selectedOngoing.eachOngoingDetails[Int(sender.tag)+1].count).updateChildValues(statusNextScheduleData) { (err, ref) in
            
            if let err = err {
                self.view.removeBluerLoader()
                self.navigationController?.setNavigationBarHidden(false, animated: true)

                self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                print(err.localizedDescription)
                return
            }
            self.eachOngoingTrainerTableView.reloadData()
            self.addNotificationDatabase(toUid: self.selectedOngoing.traineeId, description: "Your trainer was confirmed training session and new schedule already.", from: "next schedule")
        }
    }
    
    func addNotificationDatabase(toUid: String, description: String, from: String) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        dateFormatter.locale = Locale(identifier: "en")
        let currentStringOfDate = dateFormatter.string(from: Date())
        
        let notificationData = ["from_uid": self.currentUser.uid,
                                "description": description,
                                "timestamp": currentStringOfDate,
                                "is_read": "0"]
        
        self.ref.child("notifications").child(toUid).childByAutoId().updateChildValues(notificationData) { (err, ref) in
            if let err = err {
                self.view.removeBluerLoader()
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                print(err.localizedDescription)
                return
            }
            if from == "change schedule" {
                self.view.removeBluerLoader()
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                self.createAlert(alertTitle: "Change schedule date and time successfully", alertMessage: "")
            } else if from == "next schedule" {
                self.view.removeBluerLoader()
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                self.createAlert(alertTitle: "Confirm training successfully", alertMessage: "")
            } else if from == "transfer money" {
                self.view.removeBluerLoader()
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                self.createAlert(alertTitle: "This course is finish!", alertMessage: "")
            } else if from == "wait review" {
                self.view.removeBluerLoader()
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                self.createAlert(alertTitle: "Confirm training successfully", alertMessage: "")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.eachOngoingTrainerTableView.tableFooterView = UIView()
    }
}
