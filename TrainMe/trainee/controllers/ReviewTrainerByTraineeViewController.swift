//
//  ReviewTrainerByTraineeViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 18/12/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class ReviewTrainerByTraineeViewController: UIViewController {

    @IBOutlet weak var ratingStackView: RatingController!
    @IBOutlet weak var reviewTv: UITextView!
    @IBOutlet weak var noteTv: UITextView!
    @IBOutlet weak var scheduleNextSessionBtn: UIButton!
    
    var ref: DatabaseReference!
    var currentUser: User!
    var trainerId: String!
    var traineeId: String!
    var ongoingId: String!
    var count: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scheduleNextSessionBtn.layer.cornerRadius = 17
        self.HideKeyboard()
        
        self.currentUser = Auth.auth().currentUser
        self.ref = Database.database().reference()
        
        self.traineeId = self.currentUser.uid
    }
    
    @IBAction func scheduleNextSessionBtnAction(_ sender: UIButton) {
        print(self.ratingStackView.starsRating)
        //TODO: Add review data to firebase
        self.addReviewDataToDatabase()
    }
    
    func addReviewDataToDatabase() {
        
        let reviewData = ["rate_point": "\(self.ratingStackView.starsRating)",
            "review": self.reviewTv.text!,
            "note": self.noteTv.text!]
        
        ref.child("progress_schedule_detail").child(self.trainerId).child(self.traineeId).child(self.ongoingId).child(self.count!).updateChildValues(reviewData) { (err, ref) in
            if let err = err {
                print(err.localizedDescription)
                self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                return
            }
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
