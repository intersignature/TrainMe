//
//  Register3ViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 22/8/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import DTTextField

class Register3ViewController: UIViewController, UITextFieldDelegate {

    private var datePicker: UIDatePicker!
    
    @IBOutlet weak var dateOfBirthView: UIView!
    @IBOutlet weak var weightView: UIView!
    @IBOutlet weak var heightView: UIView!
    @IBOutlet weak var genderView: UIView!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var dateOfBirthTf: DTTextField!
    @IBOutlet weak var weightTf: DTTextField!
    @IBOutlet weak var heightTf: DTTextField!
    @IBOutlet weak var maleBtn: UIButton!
    @IBOutlet weak var femaleBtn: UIButton!
    @IBOutlet weak var noneBtn: UIButton!
    @IBOutlet weak var registerLb: UILabel!
    @IBOutlet weak var kgLb: UILabel!
    @IBOutlet weak var cmLb: UILabel!
    @IBOutlet weak var termLineOneLb: UILabel!
    @IBOutlet weak var termLineTwoLb: UILabel!
    
    var userProfile: UserProfile = UserProfile()
    var email: String?
    var password: String?
    var checkGender: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dateOfBirthView.layer.cornerRadius = 17
        weightView.layer.cornerRadius = 17
        heightView.layer.cornerRadius = 17
        genderView.layer.cornerRadius = 17
        submitBtn.layer.cornerRadius = 17
        maleBtn.layer.cornerRadius = 5
        femaleBtn.layer.cornerRadius = 5
        noneBtn.layer.cornerRadius = 5
        
        self.weightTf.delegate = self
        self.heightTf.delegate = self
        
        self.HideKeyboard()
        print(self.userProfile.getData())
        print(self.email)
        self.createPickerToolbar()
        setLocalizeText()
        dateOfBirthTf.layer.cornerRadius = 17

        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateChange(datePicker:)), for: .valueChanged)

        let tabGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tabGesture)

        dateOfBirthTf.inputView = datePicker
    }
    
    func setLocalizeText() {
        
        registerLb.text = NSLocalizedString("register", comment: "")
        weightTf.placeholder = NSLocalizedString("weight", comment: "")
        kgLb.text = NSLocalizedString("kg", comment: "")
        heightTf.placeholder = NSLocalizedString("height", comment: "")
        cmLb.text = NSLocalizedString("cm", comment: "")
        maleBtn.setTitle(NSLocalizedString("male", comment: ""), for: .normal)
        femaleBtn.setTitle(NSLocalizedString("female", comment: ""), for: .normal)
        noneBtn.setTitle(NSLocalizedString("none", comment: ""), for: .normal)
        termLineOneLb.text = NSLocalizedString("term_line1", comment: "")
        termLineTwoLb.text = NSLocalizedString("term_line2", comment: "")
        submitBtn.setTitle(NSLocalizedString("submit", comment: ""), for: .normal)
    }
    
    func createPickerToolbar() {
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneBtn = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.dismissKeyboard))
        toolbar.setItems([doneBtn], animated: false)
        toolbar.isUserInteractionEnabled = true
        self.dateOfBirthTf.inputAccessoryView = toolbar
    }
    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    @objc func dateChange(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"

        dateOfBirthTf.text = dateFormatter.string(from: datePicker.date)
//        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
//        dayOfBirthTf.resignFirstResponder()
        weightTf.resignFirstResponder()
        heightTf.resignFirstResponder()
        return true
    }

    @IBAction func backBtnAction(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func maleBtnAction(_ sender: UIButton) {
        
        maleBtn.backgroundColor = UIColor(red: 51/255.0, green: 51/255.0, blue: 153/255.0, alpha: 1)
        maleBtn.setTitleColor(UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1), for: .normal)
        
        femaleBtn.backgroundColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1)
        femaleBtn.setTitleColor(UIColor(red: 51/255.0, green: 51/255.0, blue: 153/255.0, alpha: 1), for: .normal)
        
        noneBtn.backgroundColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1)
        noneBtn.setTitleColor(UIColor(red: 51/255.0, green: 51/255.0, blue: 153/255.0, alpha: 1), for: .normal)
        
        checkGender = 1
    }
    
    
    @IBAction func femaleBtnAction(_ sender: UIButton) {
        
        maleBtn.backgroundColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1)
        maleBtn.setTitleColor(UIColor(red: 51/255.0, green: 51/255.0, blue: 153/255.0, alpha: 1), for: .normal)
        
        femaleBtn.backgroundColor = UIColor(red: 51/255.0, green: 51/255.0, blue: 153/255.0, alpha: 1)
        femaleBtn.setTitleColor(UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1), for: .normal)
        
        noneBtn.backgroundColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1)
        noneBtn.setTitleColor(UIColor(red: 51/255.0, green: 51/255.0, blue: 153/255.0, alpha: 1), for: .normal)
        
        checkGender = 2
    }
    
    
    @IBAction func noneBtnAction(_ sender: UIButton) {
        
        maleBtn.backgroundColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1)
        maleBtn.setTitleColor(UIColor(red: 51/255.0, green: 51/255.0, blue: 153/255.0, alpha: 1), for: .normal)
        
        femaleBtn.backgroundColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1)
        femaleBtn.setTitleColor(UIColor(red: 51/255.0, green: 51/255.0, blue: 153/255.0, alpha: 1), for: .normal)
        
        noneBtn.backgroundColor = UIColor(red: 51/255.0, green: 51/255.0, blue: 153/255.0, alpha: 1)
        noneBtn.setTitleColor(UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1), for: .normal)
        
        checkGender = -1
    }

    @IBAction func submitBtnAction(_ sender: UIButton) {
        
        if self.checkData() {
            self.view.showBlurLoader()
            self.createUserWithEmail()
        }
    }
    
    func checkData() -> Bool{
        
        if self.dateOfBirthTf.text == "" {
            self.createAlert(alertTitle: NSLocalizedString("please_enter_your_date_of_birth", comment: ""), alertMessage: "")
            return false
        } else {
            userProfile.dateOfBirth = self.dateOfBirthTf.text!
        }
        
        if weightTf.text == "" {
            self.createAlert(alertTitle: "Please enter your weight", alertMessage: "")
            return false
        } else {
            userProfile.weight = weightTf.text!
        }
        
        if heightTf.text == "" {
            self.createAlert(alertTitle: "Please enter your height", alertMessage: "")
            return false
        } else {
            userProfile.height = heightTf.text!
        }
        
        if checkGender == -1 {
            userProfile.gender = "-1"
        } else if checkGender == 1 {
            userProfile.gender = "male"
        } else if checkGender == 2 {
            userProfile.gender = "female"
        }
        return true
    }
    
    func createUserWithEmail() {
        
        Auth.auth().createUser(withEmail: self.email!, password: self.password!) { (user, err) in
            if let err = err {
                self.view.removeBluerLoader()
                self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                
                return
            }
            
            let profileChangeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            profileChangeRequest?.displayName = self.userProfile.fullName
            profileChangeRequest?.commitChanges(completion: { (err) in
                if let err = err {
                    print(err)
                    self.view.removeBluerLoader()
                    self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                    return
                }
                print("displayname: \(Auth.auth().currentUser?.displayName)")
                print("photoname: \(Auth.auth().currentUser?.photoURL?.absoluteString)")
            })
            print("Create user with email success!")
            self.addProfileToDatabase()
        }
    }
    
    func addProfileToDatabase() {
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let dictionaryValues = ["role": "trainee",
                                "name": self.userProfile.fullName,
                                "email": self.userProfile.email,
                                "dateOfBirth": self.userProfile.dateOfBirth,
                                "weight": self.userProfile.weight,
                                "height": self.userProfile.height,
                                "gender": self.userProfile.gender,
                                "profileImageUrl": "-1",
                                "omise_cus_id": "-1"]
        let values = [uid: dictionaryValues]
        Database.database().reference().child("user").updateChildValues(values) { (err, reference) in
            if let err = err {
                print(err)
                self.view.removeBluerLoader()
                return
            }
            print("Successfully save user info into firebase database!")
            self.view.removeBluerLoader()
            self.performSegue(withIdentifier: "Register3ToMain", sender: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
