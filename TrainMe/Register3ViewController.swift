//
//  Register3ViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 22/8/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit

class Register3ViewController: UIViewController {

//    @IBOutlet weak var dateOfBirthTf: UITextField!
//    private var datePicker: UIDatePicker!
    
    @IBOutlet weak var weightView: UIView!
    @IBOutlet weak var heightView: UIView!
    @IBOutlet weak var genderView: UIView!
    @IBOutlet weak var submitBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        weightView.layer.cornerRadius = 17
        heightView.layer.cornerRadius = 17
        genderView.layer.cornerRadius = 17
        submitBtn.layer.cornerRadius = 17
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
        // Do any additional setup after loading the view.
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
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
