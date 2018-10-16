//
//  NewProgressViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 19/9/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class NewProgressViewController: UIViewController {

    var selectedCourse: Course!
    var selectedBookDetail: BookPlaceDetail!
    var selectedPlaceId: String!
    
    var ref: DatabaseReference!
    var currentUser: User!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.ref = Database.database().reference()
        self.currentUser = Auth.auth().currentUser
        
        self.addDataToDatabase()
    }
    
    func addDataToDatabase() {
        
        let mainData = ["course_id": self.selectedCourse.key,
                    "place_id": self.selectedPlaceId,
                    "transaction_to_admin": "-1"]
        
        let subTimeSchedule = ["start_train_date": self.selectedBookDetail.startTrainDate,
                               "start_train_time": self.selectedBookDetail.startTrainTime,
                               "status": "1",
                               "transaction_to_trainer": "-1"]
        
        ref.child("progress_schedule_detail").child(self.currentUser.uid).child(self.selectedBookDetail.trainerId).childByAutoId().updateChildValues(mainData) { (err, ref) in
            if let err = err {
                print(err.localizedDescription)
                self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                return
            }
            print("asdasd = \(ref.key)")
            print("successfully add main data")
            
            ref.childByAutoId().updateChildValues(subTimeSchedule, withCompletionBlock: { (err2, ref) in
                if let err2 = err2 {
                    print(err2.localizedDescription)
                    self.createAlert(alertTitle: err2.localizedDescription, alertMessage: "")
                    return
                }
            })
        }
        print("successfully add sub time schedule")
        
//        ref.child("progress_schedule_detail").child(self.currentUser.uid).child(self.selectedBookDetail.trainerId).childByAutoId().updateChildValues(subTimeSchedule) { (err, ref) in
//            if let err = err {
//                print(err.localizedDescription)
//                self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
//                return
//            }
//        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupNavigationStyle()
    }
}
