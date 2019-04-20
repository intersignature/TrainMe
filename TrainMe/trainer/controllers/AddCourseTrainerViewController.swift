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
    @IBOutlet weak var courseVideoUrlTf: DTTextField!
    @IBOutlet weak var courseTypeTf: DTTextField!
    @IBOutlet weak var timeOfCourseTf: DTTextField!
    @IBOutlet weak var courseDurationTf: DTTextField!
    @IBOutlet weak var courseLevelTf: DTTextField!
    @IBOutlet weak var coursePriceTf: DTTextField!
    @IBOutlet weak var courseLanguageTf: DTTextField!
    @IBOutlet weak var addBtn: UIButton!
    
    @IBOutlet weak var courseContentLb: UILabel!
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        courseTf.delegate = self
        courseDetailTv.delegate = self
        courseVideoUrlTf.delegate = self
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
            courseTypeTf.text = "healthy".localized()
            selectedType = "healthy".localized()
        }
        levelPicker.tag = 2
    }
    
    @objc func courseLevelTfAction(textField: DTTextField) {
        
        if courseLevelTf.text == "" {
            courseLevelTf.text = "all_level".localized()
            selectedLevel = "all_level".localized()
        }
        levelPicker.tag = 1
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        courseTf.resignFirstResponder()
        courseVideoUrlTf.resignFirstResponder()
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
        
        self.dismissKeyboard()
        self.view.showBlurLoader()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        addCourseToDatabase()
    }
    
    @IBAction func cancelBarBtnAction(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        setupNavigationStyle()
        
        title = "add_course".localized()
        
        self.courseTf.placeholder = "course".localized()
        self.courseContentLb.text = "course_content".localized()
        self.courseVideoUrlTf.placeholder = "course_video_id".localized()
        self.courseDetailTv.text = "course_detail".localized()
        self.courseTypeTf.placeholder = "course_type".localized()
        self.timeOfCourseTf.placeholder = "time_of_course".localized()
        self.courseDurationTf.placeholder = "course_duration".localized()
        self.courseLevelTf.placeholder = "course_level".localized()
        self.coursePriceTf.placeholder = "course_price".localized()
        self.courseLanguageTf.placeholder = "course_language".localized()
        self.addBtn.setTitle("add".localized(), for: .normal)
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
        let doneBtn = UIBarButtonItem(title: "done".localized(), style: .plain, target: self, action: #selector(self.dismissKeyboard))
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
        let courseVideoId = courseVideoUrlTf.text
        let courseType = courseTypeTf.text
        let timeOfCourse = timeOfCourseTf.text
        let courseDuration = courseDurationTf.text
        let courseLevel = courseLevelTf.text
        let coursePrice = coursePriceTf.text
        let courseLanguage = courseLanguageTf.text
        
        if !checkTextfield(course_name: courseName!, course_content: courseContent!, courseVideoId: courseVideoId!, course_type: courseType!, time_of_course: timeOfCourse!, course_duration: courseDuration!, course_level: courseLevel!, course_price: coursePrice!, course_language: courseLanguage!) {
            self.view.removeBluerLoader()
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            createAlert(alertTitle: "please_fill_in_the_blank".localized(), alertMessage: "")
            return
        }
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        let dictionaryValues = ["course_name": courseName,
                                "course_content": courseContent,
                                "course_video_url": courseVideoId,
                                "course_type": encryptedCourseType(courseType: courseType!),
                                "time_of_course": timeOfCourse,
                                "course_duration": courseDuration,
                                "course_level": encryptedCourseLevel(courseLevel: courseLevel!),
                                "course_price": coursePrice,
                                "course_language": courseLanguage]
        
        Database.database().reference().child("courses").child(uid).childByAutoId().updateChildValues(dictionaryValues) { (err, reference) in
            self.view.removeBluerLoader()
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            if let err = err {
                print(err.localizedDescription)
                self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                return
            }
            print("successfully add course to database")
            let alert = UIAlertController(title: "successfully_add_course".localized(), message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: { (action) in
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
    
        }
    }
    
    func encryptedCourseType(courseType: String) -> String {
        
        let courseTypeCode = ["healthy".localized(), "fit_and_firm".localized(), "competition".localized()]
        return String(courseTypeCode.firstIndex(of: courseType.localized())!+1)
    }
    
    func encryptedCourseLevel(courseLevel: String) -> String {
        
        let courseLevelCode = ["all_level".localized(), "intermediate".localized(), "beginner".localized(), "expert".localized()]
        return String(courseLevelCode.firstIndex(of: courseLevel.localized())!+1)
    }
    
    func checkTextfield(course_name: String, course_content: String, courseVideoId: String, course_type: String, time_of_course: String,
                        course_duration: String, course_level: String, course_price: String, course_language: String) -> Bool {
        
        if course_name == "" || course_content == "" || courseVideoId == "" || course_type == "" || time_of_course == "" ||
            course_duration == "" || course_level == "" || course_price == "" || course_language == "" {
            return false
        }
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
