//
//  EditCourseViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 7/9/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import DTTextField
import FirebaseAuth
import FirebaseDatabase

class EditCourseViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var courseName: DTTextField!
    @IBOutlet weak var courseDetail: UITextView!
    @IBOutlet weak var courseType: DTTextField!
    @IBOutlet weak var timeOfCourse: DTTextField!
    @IBOutlet weak var courseDuration: DTTextField!
    @IBOutlet weak var courseLevel: DTTextField!
    @IBOutlet weak var coursePrice: DTTextField!
    @IBOutlet weak var courseLanguage: DTTextField!
    @IBOutlet weak var editBtn: UIButton!
    
    @IBOutlet weak var courseContentLb: UILabel!
    
    var currentUser: User?
    var ref: DatabaseReference = DatabaseReference()
    let levelPicker = UIPickerView()
    let typePicker = UIPickerView()
    let levels = ["all_level".localized(),
                  "beginner".localized(),
                  "intermediate".localized(),
                  "expert".localized()]
    let types = ["healthy".localized(),
                 "fit_and_firm".localized(),
                 "competition".localized()]
    var selectedLevel: String?
    var selectedType: String?
    var course:Course = Course()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentUser = (Auth.auth().currentUser)!
        ref = Database.database().reference()
        
        courseName.delegate = self
        courseType.delegate = self
        timeOfCourse.delegate = self
        courseDuration.delegate = self
        courseLevel.delegate = self
        coursePrice.delegate = self
        courseLanguage.delegate = self
        
        editBtn.layer.cornerRadius = 17
        self.HideKeyboard()
        createLevelPicker()
        createTypePicker()
        createPickerToolbar()
        
        courseName.text = course.course
        courseDetail.text = course.courseContent
        courseType.text = course.courseType
        timeOfCourse.text = course.timeOfCourse
        courseDuration.text = course.courseDuration
        courseLevel.text = course.courseLevel
        coursePrice.text = course.coursePrice
        courseLanguage.text = course.courseLanguage
        
        courseType.addTarget(self, action: #selector(courseTypeTfAction), for: UIControlEvents.editingDidBegin)
        courseLevel.addTarget(self, action: #selector(courseLevelTfAction), for: UIControlEvents.editingDidBegin)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setupNavigationStyle()
        
        self.courseName.placeholder = "course".localized()
        self.courseContentLb.text = "course_content".localized()
        self.courseType.placeholder = "course_type".localized()
        self.timeOfCourse.placeholder = "time_of_course".localized()
        self.courseDuration.placeholder = "course_duration".localized()
        self.courseLevel.placeholder = "course_level".localized()
        self.coursePrice.placeholder = "course_price".localized()
        self.courseLanguage.placeholder = "course_language".localized()
        self.editBtn.setTitle("edit".localized(), for: .normal)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    @IBAction func cancelBtnAction(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func courseTypeTfAction(textField: DTTextField) {
        
        if courseType.text == "" {
            courseType.text = "healthy".localized()
            selectedType = "healthy".localized()
        }
        levelPicker.tag = 2
    }
    
    @objc func courseLevelTfAction(textField: DTTextField) {
        
        if courseLevel.text == "" {
            courseLevel.text = "all_level".localized()
            selectedLevel = "all_level".localized()
        }
        levelPicker.tag = 1
    }
    
    func createLevelPicker() {
        
        levelPicker.delegate = self
        courseLevel.inputView = levelPicker
        levelPicker.tag = 1
    }
    
    func createTypePicker() {
        
        typePicker.delegate = self
        courseType.inputView = typePicker
        typePicker.tag = 2
    }
    
    func createPickerToolbar() {
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneBtn = UIBarButtonItem(title: "done".localized(), style: .plain, target: self, action: #selector(self.dismissKeyboard))
        toolbar.setItems([doneBtn], animated: false)
        toolbar.isUserInteractionEnabled = true
        courseLevel.inputAccessoryView = toolbar
        courseType.inputAccessoryView = toolbar
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        courseName.resignFirstResponder()
        courseType.resignFirstResponder()
        timeOfCourse.resignFirstResponder()
        courseDuration.resignFirstResponder()
        courseLevel.resignFirstResponder()
        coursePrice.resignFirstResponder()
        courseLanguage.resignFirstResponder()
        return true
    }
    
    override func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        courseDetail.resignFirstResponder()
        return true
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
            courseLevel.text = selectedLevel
            print(selectedLevel)
        } else {
            selectedType = types[row]
            courseType.text = selectedType
            print(selectedType)
        }
    }

    @IBAction func editBtnAction(_ sender: UIButton) {
        
        self.dismissKeyboard()
        self.view.showBlurLoader()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        let courseName = self.courseName.text
        let courseContent = self.courseDetail.text
        let courseType = self.courseType.text
        let timeOfCourse = self.timeOfCourse.text
        let courseDuration = self.courseDuration.text
        let courseLevel = self.courseLevel.text
        let coursePrice = self.coursePrice.text
        let courseLanguage = self.courseLanguage.text

        if !checkTextfield(course_name: courseName!, course_content: courseContent!, course_type: courseType!, time_of_course: timeOfCourse!, course_duration: courseDuration!, course_level: courseLevel!, course_price: coursePrice!, course_language: courseLanguage!) {
            self.view.removeBluerLoader()
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            createAlert(alertTitle: "please_fill_in_the_blank".localized(), alertMessage: "")
            return
        }

        let dictionaryValues = ["course_name": courseName,
                                "course_content": courseContent,
                                "course_type": courseType,
                                "time_of_course": timeOfCourse,
                                "course_duration": courseDuration,
                                "course_level": courseLevel,
                                "course_price": coursePrice,
                                "course_language": courseLanguage]

        let uid = self.currentUser?.uid
        ref.child("courses").child(uid!).child(course.key).updateChildValues(dictionaryValues) { (err, ref) in
            self.view.removeBluerLoader()
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            if let err = err {
                print(err.localizedDescription)
                self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                return
            }
        
        print("successfully edit course to database")
        
        let alert = UIAlertController(title: "successfully_edit_course".localized(), message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
        
//        self.course = Course(key: self.course.key,
//                             course: courseName!,
//                             courseContent: courseContent!,
//                             courseType: courseType!,
//                             timeOfCourse: timeOfCourse!,
//                             courseDuration: courseDuration!,
//                             courseLevel: courseLevel!,
//                             coursePrice: coursePrice!,
//                             courseLanguage: courseLanguage!)
        }
    }
    
    func checkTextfield(course_name: String, course_content: String, course_type: String, time_of_course: String,
                        course_duration: String, course_level: String, course_price: String, course_language: String) -> Bool {

        if course_name == "" || course_content == "" || course_type == "" || time_of_course == "" ||
            course_duration == "" || course_level == "" || course_price == "" || course_language == "" {
            return false
        }
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
