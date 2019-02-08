//
//  ReportViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 8/2/2562 BE.
//  Copyright © 2562 Sirichai Binchai. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ReportViewController: UIViewController {

    @IBOutlet weak var reportTv: UITextView!
    @IBOutlet weak var confirmReportBtn: UIButton!
    
    var trainerId: String!
    var courseId: String!
    
    var ref: DatabaseReference!
    var currentUser: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ref = Database.database().reference()
        self.currentUser = Auth.auth().currentUser
        
        self.confirmReportBtn.layer.cornerRadius = 17
        
        self.reportTv.layer.borderWidth = 1
        self.reportTv.layer.borderColor = UIColor.black.cgColor
        self.reportTv.layer.cornerRadius = 5
    }
    
    @IBAction func confirmReportBtnAction(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Confirm to report", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            if self.reportTv.text == "" {
                self.createAlert(alertTitle: "Please fill in the blank", alertMessage: "")
                return
            } else {
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                self.view.showBlurLoader()
                self.addDataToReportDatabase()
            }
        }))
        alert.addAction(UIAlertAction(title: "No", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func addDataToReportDatabase() {
        
        let reportData = ["course_id": self.courseId,
                          "report_content": self.reportTv.text]
        
        self.ref.child("report").child(self.trainerId).child(self.currentUser.uid).childByAutoId().updateChildValues(reportData) { (err, ref) in
            
            if let err = err {
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                self.view.removeBluerLoader()
                print(err.localizedDescription)
                self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                return
            }
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.view.removeBluerLoader()
            let alert = UIAlertController(title: "Add report successfully!", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelBtnAction(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupNavigationStyle()
    }
}
