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

class Register3ViewController: UIViewController, UITextFieldDelegate {

//    @IBOutlet weak var dateOfBirthTf: UITextField!
//    private var datePicker: UIDatePicker!
    
    @IBOutlet weak var weightView: UIView!
    @IBOutlet weak var heightView: UIView!
    @IBOutlet weak var genderView: UIView!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var dayOfBirthTf: UITextField!
    @IBOutlet weak var monthOfBirthTf: UITextField!
    @IBOutlet weak var yearOfBirthTf: UITextField!
    @IBOutlet weak var weightTf: UITextField!
    @IBOutlet weak var heightTf: UITextField!
    @IBOutlet weak var maleBtn: UIButton!
    @IBOutlet weak var femaleBtn: UIButton!
    @IBOutlet weak var noneBtn: UIButton!
    @IBOutlet weak var registerLb: UILabel!
    @IBOutlet weak var dateOfBirthLb: UILabel!
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

        weightView.layer.cornerRadius = 17
        heightView.layer.cornerRadius = 17
        genderView.layer.cornerRadius = 17
        submitBtn.layer.cornerRadius = 17
        maleBtn.layer.cornerRadius = 5
        femaleBtn.layer.cornerRadius = 5
        noneBtn.layer.cornerRadius = 5
        
        self.dayOfBirthTf.delegate = self
        self.monthOfBirthTf.delegate = self
        self.yearOfBirthTf.delegate = self
        self.weightTf.delegate = self
        self.heightTf.delegate = self
        
        self.HideKeyboard()
        print(self.userProfile.getData())
        print(self.email)
        print(self.password)
        setLocalizeText()
//        dateOfBirthTf.layer.cornerRadius = 17
//
//        datePicker = UIDatePicker()
//        datePicker.datePickerMode = .date
//        datePicker.addTarget(self, action: #selector(dateChange(datePicker:)), for: .valueChanged)
//
//        let tabGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(gestureRecognizer:)))
//        view.addGestureRecognizer(tabGesture)
//
//        dateOfBirthTf.inputView = datePicker
    }
    
    func setLocalizeText() {
        
        registerLb.text = NSLocalizedString("register", comment: "")
        dateOfBirthLb.text = NSLocalizedString("date_of_birth", comment: "")
        dayOfBirthTf.placeholder = NSLocalizedString("dd", comment: "")
        monthOfBirthTf.placeholder = NSLocalizedString("mm", comment: "")
        yearOfBirthTf.placeholder = NSLocalizedString("yyyy", comment: "")
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
    
//    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
//        view.endEditing(true)
//    }
//
//    @objc func dateChange(datePicker: UIDatePicker) {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "dd/MM/yyyy"
//
//        dateOfBirthTf.text = dateFormatter.string(from: datePicker.date)
////        view.endEditing(true)
//    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        dayOfBirthTf.resignFirstResponder()
        monthOfBirthTf.resignFirstResponder()
        yearOfBirthTf.resignFirstResponder()
        weightTf.resignFirstResponder()
        heightTf.resignFirstResponder()
        return true
    }
    
    func backTrainsition(segueId: String) {
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        view.window!.layer.add(transition, forKey: kCATransition)
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func backBtnAction(_ sender: UIButton) {
        
        backTrainsition(segueId: "Register3ToRegister2")
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
        
        if dayOfBirthTf.text == "" && monthOfBirthTf.text == "" && yearOfBirthTf.text == "" {
            
            createAlert(alertTitle: NSLocalizedString("please_enter_your_date_of_birth", comment: ""), alertMessage: "")
            return
        } else {
            userProfile.dateOfBirth = "\(String(describing: dayOfBirthTf.text!))/\(String(describing: monthOfBirthTf.text!))/\(String(describing: yearOfBirthTf.text!))"
        }
        
        if weightTf.text == "" {
            userProfile.weight = "-1"
        } else {
            userProfile.weight = weightTf.text!
        }
        
        if heightTf.text == "" {
            userProfile.height = "-1"
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
        
        print(self.userProfile.getData())
        print(self.email!)
        print(self.password!)
        self.view.showBlurLoader()
        self.createUserWithEmail()
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
        let dictionaryValues = ["role": "trainer",
                                "dateOfBirth": self.userProfile.dateOfBirth,
                                "weight": self.userProfile.weight,
                                "height": self.userProfile.height,
                                "gender": self.userProfile.gender]
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
