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
    
    let levels = ["All level",
                 "Intermediate",
                 "Beginner",
                 "Expert"]
    
    var selectedLevel: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
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
        createPickerToolbar()
        
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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
        let levelPicker = UIPickerView()
        levelPicker.delegate = self
        courseLevelTf.inputView = levelPicker
    }
    
    func createPickerToolbar() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneBtn = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.dismissKeyboard))
        toolbar.setItems([doneBtn], animated: false)
        toolbar.isUserInteractionEnabled = true
        courseLevelTf.inputAccessoryView = toolbar
    }
    
    override func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return levels.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return levels[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedLevel = levels[row]
        courseLevelTf.text = selectedLevel
        print(selectedLevel)
    }

    func addCourseToDatabase() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let dictionaryValues = ["course_name": courseTf.text ?? "",
                                "course_content": courseDetailTv.text ?? "",
                                "course_type": courseTypeTf.text ?? "",
                                "time_of_course": timeOfCourseTf.text ?? "",
                                "course_duration": courseDurationTf.text ?? "",
                                "course_level": courseLevelTf.text ?? "",
                                "course_price": coursePriceTf.text ?? "",
                                "course_language": courseLanguageTf.text ?? ""]
        Database.database().reference().child("courses").child(uid).childByAutoId().updateChildValues(dictionaryValues) { (err, reference) in
            if let err = err {
                print(err)
                return
            }
            print("successfully add course to database")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
