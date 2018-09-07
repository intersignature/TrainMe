//
//  EditCourseViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 7/9/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import DTTextField

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
        
        courseType.addTarget(self, action: #selector(courseTypeTfAction), for: UIControlEvents.editingDidBegin)
        courseLevel.addTarget(self, action: #selector(courseLevelTfAction), for: UIControlEvents.editingDidBegin)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setupNavigationStyle()
    }
    
    @IBAction func cancelBtnAction(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func courseTypeTfAction(textField: DTTextField) {
        
        if courseType.text == "" {
            courseType.text = "Healthy"
            selectedType = "Healthy"
        }
        levelPicker.tag = 2
    }
    
    @objc func courseLevelTfAction(textField: DTTextField) {
        
        if courseLevel.text == "" {
            courseLevel.text = "All level"
            selectedLevel = "All level"
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
        let doneBtn = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.dismissKeyboard))
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
