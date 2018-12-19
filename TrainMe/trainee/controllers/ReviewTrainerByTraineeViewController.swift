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

class ReviewTrainerByTraineeViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var ratingStackView: RatingController!
    @IBOutlet weak var reviewTv: UITextView!
    @IBOutlet weak var noteTv: UITextView!
    @IBOutlet weak var scheduleNextSessionBtn: UIButton!
    
    @IBOutlet weak var nextScheduleDateTv: DTTextField!
    @IBOutlet weak var nextScheduleTimeTv: DTTextField!
    
    var ref: DatabaseReference!
    var currentUser: User!
    var trainerId: String!
    var traineeId: String!
    var ongoingId: String!
    var count: String!
    
    var datePicker: UIDatePicker!
    var timePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    }
    
    @IBAction func scheduleNextSessionBtnAction(_ sender: UIButton) {
        print(self.ratingStackView.starsRating)
        
        self.addReviewDataToDatabase()
    }
    
    func addReviewDataToDatabase() {
        
        if checkNextSchedule() {
            
            self.checkTrainerIsConfirm()
        } else {
            self.createAlert(alertTitle: "Please fill next schedule date and time", alertMessage: "")
            return
        }
    }
    
    func checkNextSchedule() -> Bool{
        return self.nextScheduleDateTv.text != "" && self.nextScheduleTimeTv.text != ""
    }
    
    func checkTrainerIsConfirm() {
        
        ref.child("progress_schedule_detail").child(self.trainerId).child(self.traineeId).child(self.ongoingId).child(self.count!).child("is_trainer_confirm").observeSingleEvent(of: .value) { (snapshot) in
            
            let isTrainerConfirm = snapshot.value as! String
            self.addReviewData(isTrainerConfirm: isTrainerConfirm)
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
        
        ref.child("progress_schedule_detail").child(self.trainerId).child(self.traineeId).child(self.ongoingId).child(self.count!).updateChildValues(reviewData) { (err, ref) in
            if let err = err {
                print(err.localizedDescription)
                self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                return
            }
            self.addNextScheduleDateAndTimeToDatabase(isTrainerConfirm: isTrainerConfirm)
        }
    }
    
    func addNextScheduleDateAndTimeToDatabase(isTrainerConfirm: String) {
        
        //TODO: Make protocol to notify ongoing progress trainee status and next schedule date and time
        //TODO: Check is_trainer_confirm and is_trainee_confirm
        var nextScheduleData = ["start_train_date": self.nextScheduleDateTv.text!,
                                "start_train_time": self.nextScheduleTimeTv.text!]
        
        if isTrainerConfirm == "1" {
            nextScheduleData = ["start_train_date": self.nextScheduleDateTv.text!,
                                "start_train_time": self.nextScheduleTimeTv.text!,
                                "status": "1"]
        }
        
        self.ref.child("progress_schedule_detail").child(self.trainerId).child(self.traineeId).child(self.ongoingId).child("\(Int(self.count)!+1)").updateChildValues(nextScheduleData) { (err, ref) in
            if let err = err {
                print(err.localizedDescription)
                self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                return
            }
            let alert = UIAlertController(title: "Review and schedule next time training successfully", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
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
        let doneBtn = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.dismissKeyboard))
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
        
        self.setupNavigationStyle()
    }
}
