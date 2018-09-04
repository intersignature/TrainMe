//
//  AddCourseTrainerViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 31/8/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import DTTextField
import FirebaseAuth
import FirebaseDatabase

class AddCourseTrainerViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var courseTf: DTTextField!
    @IBOutlet weak var courseDetailTv: UITextView!
    @IBOutlet weak var courseTypeTf: DTTextField!
    @IBOutlet weak var timeOfCourseTf: DTTextField!
    @IBOutlet weak var courseDurationTf: DTTextField!
    @IBOutlet weak var courseLevelTf: DTTextField!
    @IBOutlet weak var coursePriceTf: DTTextField!
    @IBOutlet weak var courseLanguageTf: DTTextField!
    @IBOutlet weak var addBtn: UIButton!
    let levelPicker = UIPickerView()
    let typePicker = UIPickerView()
    let levels = ["All level",
                 "Intermediate",
                 "Beginner",
                 "Expert"]
    let types = ["Healthy",
                 "Fit and firm",
                 "Competition"]
    var selectedLevel: String?
    var selectedType: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        courseTf.delegate = self
        courseDetailTv.delegate = self
        courseTypeTf.delegate = self
        timeOfCourseTf.delegate = self
        courseDurationTf.delegate = self
        courseLevelTf.delegate = self
        coursePriceTf.delegate = self
        courseLanguageTf.delegate = self
        
        addBtn.layer.cornerRadius = 17
        
        self.HideKeyboard()
        createLevelPicker()
        createTypePicker()
        createPickerToolbar()
        
        courseTypeTf.addTarget(self, action: #selector(courseTypeTfAction), for: UIControlEvents.editingDidBegin)
        courseLevelTf.addTarget(self, action: #selector(courseLevelTfAction), for: UIControlEvents.editingDidBegin)
    }
    
    @objc func courseTypeTfAction(textField: DTTextField) {
        
        if courseTypeTf.text == "" {
            courseTypeTf.text = "Healthy"
            selectedType = "Healthy"
        }
        levelPicker.tag = 2
    }
    
    @objc func courseLevelTfAction(textField: DTTextField) {
        
        if courseLevelTf.text == "" {
            courseLevelTf.text = "All level"
            selectedLevel = "All level"
        }
        levelPicker.tag = 1
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        courseTf.resignFirstResponder()
        courseTypeTf.resignFirstResponder()
        timeOfCourseTf.resignFirstResponder()
        courseDurationTf.resignFirstResponder()
        courseLevelTf.resignFirstResponder()
        coursePriceTf.resignFirstResponder()
        courseLanguageTf.resignFirstResponder()
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        
        courseDetailTv.resignFirstResponder()
        return true
    }
    
    @IBAction func AddBtnAction(_ sender: UIButton) {
        
        addCourseToDatabase()
    }
    
    @IBAction func cancelBarBtnAction(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        setupNavigationStyle()
    }
    
    func createLevelPicker() {
        
        levelPicker.delegate = self
        courseLevelTf.inputView = levelPicker
        levelPicker.tag = 1
    }
    
    func createTypePicker() {
        
        typePicker.delegate = self
        courseTypeTf.inputView = typePicker
        typePicker.tag = 2
    }
    
    func createPickerToolbar() {
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneBtn = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.dismissKeyboard))
        toolbar.setItems([doneBtn], animated: false)
        toolbar.isUserInteractionEnabled = true
        courseLevelTf.inputAccessoryView = toolbar
        courseTypeTf.inputAccessoryView = toolbar
    }
    
    override func dismissKeyboard() {
        
        view.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if levelPicker.tag == 1 {
            return levels.count
        } else {
            return types.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if levelPicker.tag == 1 {
            return levels[row]
        } else {
            return types[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if levelPicker.tag == 1 {
            selectedLevel = levels[row]
            courseLevelTf.text = selectedLevel
            print(selectedLevel)
        } else {
            selectedType = types[row]
            courseTypeTf.text = selectedType
            print(selectedType)
        }
    }

    func addCourseToDatabase() {
        
        let courseName = courseTf.text
        let courseContent = courseDetailTv.text
        let courseType = courseTypeTf.text
        let timeOfCourse = timeOfCourseTf.text
        let courseDuration = courseDurationTf.text
        let courseLevel = courseLevelTf.text
        let coursePrice = coursePriceTf.text
        let courseLanguage = courseLanguageTf.text
        
        if !checkTextfield(course_name: courseName!, course_content: courseContent!, course_type: courseType!, time_of_course: timeOfCourse!, course_duration: courseDuration!, course_level: courseLevel!, course_price: coursePrice!, course_language: courseLanguage!) {
            return
        }
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        let dictionaryValues = ["course_name": courseName,
                                "course_content": courseContent,
                                "course_type": courseType,
                                "time_of_course": timeOfCourse,
                                "course_duration": courseDuration,
                                "course_level": courseLevel,
                                "course_price": coursePrice,
                                "course_language": courseLanguage]
        
        Database.database().reference().child("courses").child(uid).childByAutoId().updateChildValues(dictionaryValues) { (err, reference) in
            if let err = err {
                print(err.localizedDescription)
                self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                return
            }
            print("successfully add course to database")
            self.dismiss(animated: true, completion: nil)
    
        }
    }
    
    func checkTextfield(course_name: String, course_content: String, course_type: String, time_of_course: String,
                        course_duration: String, course_level: String, course_price: String, course_language: String) -> Bool {
        
        if course_name == "" || course_content == "" || course_type == "" || time_of_course == "" ||
            course_duration == "" || course_level == "" || course_price == "" || course_language == "" {
            
            createAlert(alertTitle: "Please enter in blank field", alertMessage: "")
            return false
        }
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
