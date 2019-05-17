//
//  ReviewTrainerByTraineeViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 18/12/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import DTTextField

class ReviewTrainerByTraineeViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var ratingStackView: RatingController!
    @IBOutlet weak var reviewLb: UILabel!
    @IBOutlet weak var reviewTv: UITextView!
    @IBOutlet weak var noteLb: UILabel!
    @IBOutlet weak var noteTv: UITextView!
    @IBOutlet weak var scheduleNextSessionBtn: UIButton!
    
    @IBOutlet weak var nextScheduleDateTv: DTTextField!
    @IBOutlet weak var nextScheduleTimeTv: DTTextField!
    @IBOutlet weak var reportBtn: UIBarButtonItem!
    
    var ref: DatabaseReference!
    var currentUser: User!
    var trainerId: String!
    var traineeId: String!
    var ongoingId: String!
    var countAtIndex: String!
    var summaryCount: String!
    var courseId: String!
    var coursePrice: String!
    var recpId: String!
    
    var datePicker: UIDatePicker!
    var timePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reportBtn.setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Chalkduster", size: 20)!], for:.normal)
        
        self.scheduleNextSessionBtn.layer.cornerRadius = 5
        
        self.nextScheduleDateTv.delegate = self
        self.nextScheduleTimeTv.delegate = self
        self.HideKeyboard()
        
        self.currentUser = Auth.auth().currentUser
        self.ref = Database.database().reference()
        
        self.traineeId = self.currentUser.uid
        
        setupDatePicker()
        setupTimePicker()
        createPickerToolbar()
        
        if Int(self.countAtIndex)! >= Int(self.summaryCount)! {
            self.nextScheduleDateTv.isHidden = true
            self.nextScheduleTimeTv.isHidden = true
            self.scheduleNextSessionBtn.setTitle("   \("finish_this_course".localized())   ", for: .normal)
        }
    }
    
    @IBAction func scheduleNextSessionBtnAction(_ sender: UIButton) {
        print(self.ratingStackView.starsRating)
        
        self.addReviewDataToDatabase()
    }
    
    func addReviewDataToDatabase() {
        
        if checkNextSchedule() && checkReviewAndNote(){
            print("checkTrainerIsConfirm")
            self.view.showBlurLoader()
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            self.checkTrainerIsConfirm()
        } else {
            self.createAlert(alertTitle: "please_fill_in_the_blank".localized(), alertMessage: "")
            return
        }
    }
    
    func checkNextSchedule() -> Bool {
        return (self.nextScheduleDateTv.text != "" && self.nextScheduleTimeTv.text != "") ||
        (Int(self.countAtIndex)! >= Int(self.summaryCount)!)
    }
    
    func checkReviewAndNote() -> Bool {
        return self.reviewTv.text != "\("review".localized()) ..." && self.noteTv.text != "\("note".localized()) ..."
    }
    
    func checkTrainerIsConfirm() {
        
        self.ref.child("progress_schedule_detail").child(self.trainerId).child(self.traineeId).child(self.ongoingId).child(self.countAtIndex!).child("is_trainer_confirm").observeSingleEvent(of: .value, with: { (snapshot) in
            
            let isTrainerConfirm = snapshot.value as! String
            self.addReviewData(isTrainerConfirm: isTrainerConfirm)
        }) { (err) in
            self.view.removeBluerLoader()
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
            return
        }
    }
    
    func addReviewData(isTrainerConfirm: String) {
        
        var reviewData = ["rate_point": "\(self.ratingStackView.starsRating)",
            "review": self.reviewTv.text!,
            "note": self.noteTv.text!,
            "is_trainee_confirm": "1"]
        
        if isTrainerConfirm == "1" {
            reviewData = ["rate_point": "\(self.ratingStackView.starsRating)",
                "review": self.reviewTv.text!,
                "note": self.noteTv.text!,
                "is_trainee_confirm": "1",
                "status": "2"]
        }
        
        ref.child("progress_schedule_detail").child(self.trainerId).child(self.traineeId).child(self.ongoingId).child(self.countAtIndex!).updateChildValues(reviewData) { (err, ref) in
            if let err = err {
                self.view.removeBluerLoader()
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                print(err.localizedDescription)
                self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                return
            }
            
            if Int(self.countAtIndex)! < Int(self.summaryCount)! {
                self.addNextScheduleDateAndTimeToDatabase(isTrainerConfirm: isTrainerConfirm)
            } else {
                if isTrainerConfirm == "1" {
                    self.transferMoneyToTrainer()
                } else {
                    self.addNotificationDatabase(toUid: self.trainerId, description: "Your trainee was reviewed already and waiting for your confirm.", from: "wait confirm last time")
                }
            }
        }
    }
    
    func transferMoneyToTrainer() {
        
        let skey = String(format: "%@:", "skey_test_5dm3tm6pj69glowba1n").data(using: String.Encoding.utf8)!.base64EncodedString()
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        guard let URL = URL(string: "https://api.omise.co/transfers") else {return}
        
        var request = URLRequest(url: URL)
        request.httpMethod = "POST"
        
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("Basic \(String(describing: skey))", forHTTPHeaderField: "Authorization")
        
        let params = "amount=\(Int(self.coursePrice)!*100)&recipient=\(self.recpId!)"
        request.httpBody = params.data(using: .utf8, allowLossyConversion: true)
        
        let task = session.dataTask(with: request) { (data, response, err) in
            DispatchQueue.main.async {
                if err == nil {
                    let statusCode = (response as! HTTPURLResponse).statusCode
                    let jsonData = try! JSONSerialization.jsonObject(with: data!, options: []) as AnyObject
                    
                    if statusCode == 200 {
                        print(jsonData)
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
        
        self.ref.child("progress_schedule_detail").child(self.trainerId).child(self.currentUser.uid).child(self.ongoingId).updateChildValues(transactionData) { (err, ref) in
            if let err = err {
                self.view.removeBluerLoader()
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                print(err.localizedDescription)
                return
            }
            self.addNotificationDatabase(toUid: self.trainerId, description: "Your trainee was reviewed and system was pay money to your account already.", from: "transfer money")
        }
    }
    
    func addNextScheduleDateAndTimeToDatabase(isTrainerConfirm: String) {
        
        var nextScheduleData = ["start_train_date": self.nextScheduleDateTv.text!,
                                "start_train_time": self.nextScheduleTimeTv.text!]
        
        if isTrainerConfirm == "1" {
            nextScheduleData = ["start_train_date": self.nextScheduleDateTv.text!,
                                "start_train_time": self.nextScheduleTimeTv.text!,
                                "status": "1"]
        }
        
        self.ref.child("progress_schedule_detail").child(self.trainerId).child(self.traineeId).child(self.ongoingId).child("\(Int(self.countAtIndex)!+1)").updateChildValues(nextScheduleData) { (err, ref) in
            if let err = err {
                self.view.removeBluerLoader()
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                print(err.localizedDescription)
                self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                return
            }
            if isTrainerConfirm == "1" {
                self.addNotificationDatabase(toUid: self.trainerId, description: "Your trainee was reviewed and selected new schedule already, Check it out!", from: "next schedule")
            } else {
                self.addNotificationDatabase(toUid: self.trainerId, description: "Your trainee was reviewed already and waiting for your confirm.", from: "wait confirm not last time")
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.nextScheduleDateTv.resignFirstResponder()
        self.timePicker.resignFirstResponder()
        return true
    }
    
    func setupDatePicker() {
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateChange(datePicker:)), for: .valueChanged)
        
        self.nextScheduleDateTv.inputView = datePicker
    }
    
    func setupTimePicker() {
        timePicker = UIDatePicker()
        timePicker.datePickerMode = .time
        timePicker.addTarget(self, action: #selector(timeChange(datePicker:)), for: .valueChanged)
        
        self.nextScheduleTimeTv.inputView = timePicker
    }
    
    @objc func dateChange(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en")
        dateFormatter.setLocalizedDateFormatFromTemplate("dd/MM/yyyy")
        
        let tempDate = dateFormatter.string(from: datePicker.date).split(separator: "/")
        self.nextScheduleDateTv.text = "\(tempDate[1])/\(tempDate[0])/\(tempDate[2])"
    }
    
    @objc func timeChange(datePicker: UIDatePicker) {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        self.nextScheduleTimeTv.text = timeFormatter.string(from: timePicker.date)
    }
    
    func createPickerToolbar() {
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneBtn = UIBarButtonItem(title: "done".localized(), style: .plain, target: self, action: #selector(self.dismissKeyboard))
        toolbar.setItems([doneBtn], animated: false)
        toolbar.isUserInteractionEnabled = true
        self.nextScheduleDateTv.inputAccessoryView = toolbar
        self.nextScheduleTimeTv.inputAccessoryView = toolbar
    }
    
    @IBAction func cancelBtnAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.reviewTv.accessibilityLabel = "review"
        self.noteTv.accessibilityLabel = "note"
        
        self.title = "review".localized()
        self.reviewLb.text = "review".localized()
        self.noteLb.text = "note".localized()
        self.reviewTv.text = "\("review".localized()) ..."
        self.noteTv.text = "\("note".localized()) ..."
        self.reviewTv.delegate = self
        self.noteTv.delegate = self
        self.nextScheduleDateTv.placeholder = "next_schedule_date".localized()
        self.nextScheduleTimeTv.placeholder = "next_schedule_time".localized()
        self.scheduleNextSessionBtn.setTitle("submit".localized(), for: .normal)
        
        self.setupNavigationStyle()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (textView.text == "\("review".localized()) ..." && textView.accessibilityLabel == "review") || (textView.text == "\("note".localized()) ..." && textView.accessibilityLabel == "note"){
            textView.text = nil
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty && textView.accessibilityLabel == "review" {
            textView.text = "\("review".localized()) ..."
        } else if textView.text.isEmpty && textView.accessibilityLabel == "note" {
            textView.text = "\("note".localized()) ..."
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
                                "is_read": "0",
                                "is_report": "0"]
        
        self.ref.child("notifications").child(toUid).childByAutoId().updateChildValues(notificationData) { (err, ref) in
            if let err = err {
                self.view.removeBluerLoader()
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                print(err.localizedDescription)
                return
            }
            self.view.removeBluerLoader()
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            if from == "next schedule" {
                let alert = UIAlertController(title: "review_and_schedule_next_time_training_successfully".localized(), message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: { (action) in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            } else if from == "transfer money" {
                let alert = UIAlertController(title: "finish_this_course_succesfully".localized(), message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: { (action) in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            } else if from == "wait confirm last time" {
                let alert = UIAlertController(title: "review_succesfully_and_waiting_for_trainer_confirm".localized(), message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: { (action) in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            } else if from == "wait confirm not last time" {
                let alert = UIAlertController(title: "review_and_schedule_next_time_training_successfully_and_waiting_for_trainer_confirm".localized(), message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: { (action) in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func reportBtnAction(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "ReviewToReport", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ReviewToReport" {
            let  vc = segue.destination as! UINavigationController
            let containVc = vc.topViewController as! ReportViewController
            containVc.trainerId = self.trainerId
            containVc.courseId = self.courseId
        }
    }
}
