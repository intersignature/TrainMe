//
//  ProfileTraineeViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 20/12/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ProfileTraineeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var reviewProfileTraineeTableView: UITableView!
    
    @IBOutlet weak var editProfileBtn: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var genderImageView: UIImageView!
    @IBOutlet weak var emailLb: UILabel!
    @IBOutlet weak var bioLb: UILabel!
    @IBOutlet weak var heightLb: UILabel!
    @IBOutlet weak var heightTagLb: UILabel!
    @IBOutlet weak var birthdayLb: UILabel!
    @IBOutlet weak var birthdayTagLb: UILabel!
    @IBOutlet weak var weightLb: UILabel!
    @IBOutlet weak var weightTagLb: UILabel!
    @IBOutlet weak var reviewLb: UILabel!
    
    var traineeProfileUid: String!
    var isBlurProfile: Bool!
    var ref: DatabaseReference!
    var currentUser: User!
    var traineeProfile: UserProfile!
    var review: [Review] = []
    var trainerObj: [String: UserProfile] = [:]
    var courseObj: [String: Course] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ref = Database.database().reference()
        self.currentUser = Auth.auth().currentUser
        
        self.checkShowEditBtn()
        self.getReviewData()
        self.getTraineeProfile()
        
        self.navigationController?.isNavigationBarHidden = true
        self.reviewProfileTraineeTableView.delegate = self
        self.reviewProfileTraineeTableView.dataSource = self
        
        self.profileImageView.isBlur(self.isBlurProfile)
        self.setProfileImageRound()
    }
    
    func checkShowEditBtn() {
        
        if self.traineeProfileUid != self.currentUser.uid {
            self.editProfileBtn.isHidden = true
        }
    }
    
    func getTraineeProfile() {
        
        self.ref.child("user").child(traineeProfileUid).observeSingleEvent(of: .value) { (snapshot) in
            
            let value = snapshot.value as! NSDictionary
            
            self.traineeProfile = UserProfile(fullName: (value["name"] as! String),
                                              email: (value["email"] as! String),
                                              dateOfBirth: (value["dateOfBirth"] as! String),
                                              weight: (value["weight"] as! String),
                                              height: (value["height"] as! String),
                                              gender: (value["gender"] as! String),
                                              role: (value["role"] as! String),
                                              profileImageUrl: (value["profileImageUrl"] as! String),
                                              uid: snapshot.key,
                                              omiseCusId: (value["omise_cus_id"] as! String),
                                              ban: (value["ban"] as! Bool))
            self.setDataToProfileView()
        }
    }
    
    func setDataToProfileView() {
        
        self.profileImageView.downloaded(from: self.traineeProfile.profileImageUrl)
        self.nameLb.text = self.traineeProfile.fullName
        if self.traineeProfile.gender == "male" {
            self.genderImageView.image = UIImage(named: "male")
        } else if self.traineeProfile.gender == "female" {
            self.genderImageView.image = UIImage(named: "female")
        } else {
//            self.genderImageView.image = UIImage(named: "")
        }
        self.emailLb.text = self.traineeProfile.email
        self.heightLb.text = "\(self.traineeProfile.height) cm"
        self.weightLb.text = "\(self.traineeProfile.weight) kg"
        self.birthdayLb.text = self.traineeProfile.dateOfBirth
        self.editProfileBtn.isEnabled = true
    }
    
    func getReviewData() {
        
        self.ref.child("progress_schedule_detail").observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value as? [String: [String: [String: AnyObject]]] else { return }
            print(value.count)
            
            value.forEach({ (trainerId, traineeList) in
                traineeList.forEach({ (traineeId, overallScheduleDetail) in
                    if traineeId == self.traineeProfileUid {
                        var allReview: [EachReview] = []
                        overallScheduleDetail.forEach({ (btnKey, detail) in
                            allReview.removeAll()
                            let lastReviewDetail = detail[String(Int(detail.count)-4)] as! NSDictionary
                            if lastReviewDetail["status"] as! String == "2" {
                                if self.trainerObj[trainerId] == nil {
                                    self.getTrainerData(trainerId: trainerId)
                                }
                                if self.courseObj[detail["course_id"] as! String] == nil {
                                    self.getCourseObj(trainerId: trainerId, courseId: detail["course_id"] as! String)
                                }
                                for i in 1...(Int(detail.count)-4){
                                    let eachReviewValue = detail[String(i)] as? NSDictionary
                                    let eachReview = EachReview(rating: eachReviewValue!["rate_point"] as! String,
                                                                reviewDesc: eachReviewValue!["review"] as! String)
                                    allReview.append(eachReview)
                                }
                                let tempReview = Review(traineeUid: traineeId,
                                                        trainerUid: trainerId,
                                                        courseId: detail["course_id"] as! String,
                                                        eachReview: allReview)
                                self.review.append(tempReview)
                                allReview.removeAll()
                            }
                        })
                    }
                })
            })
        }
    }
    
    func getTrainerData(trainerId: String) {
        
        self.ref.child("user").child(trainerId).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as! NSDictionary
            self.trainerObj[trainerId] = UserProfile(fullName: (value["name"] as! String),
                                                     email: (value["email"] as! String),
                                                     dateOfBirth: (value["dateOfBirth"] as! String),
                                                     weight: (value["weight"] as! String),
                                                     height: (value["height"] as! String),
                                                     gender: (value["gender"] as! String),
                                                     role: (value["role"] as! String),
                                                     profileImageUrl: (value["profileImageUrl"] as! String),
                                                     omiseCusId: (value["omise_cus_id"] as! String),
                                                     ban: (value["ban"] as! Bool))
            self.trainerObj[trainerId]?.uid = trainerId
            self.reviewProfileTraineeTableView.reloadData()
        }) { (err) in
            print(err.localizedDescription)
            self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
            return
        }
    }
    
    func getCourseObj(trainerId: String, courseId: String) {
        
        ref.child("courses").child(trainerId).child(courseId).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as! NSDictionary
            
            self.courseObj[courseId] = Course(key: snapshot.key,
                                              course: value["course_name"] as! String,
                                              courseContent: value["course_content"] as! String,
                                              courseVideoUrl: value["course_video_url"]  as! String,
                                              courseType: value["course_type"] as! String,
                                              timeOfCourse: value["time_of_course"] as! String,
                                              courseDuration: value["course_duration"] as! String,
                                              courseLevel: value["course_level"] as! String,
                                              coursePrice: value["course_price"] as! String,
                                              courseLanguage: value["course_language"] as! String)
            self.reviewProfileTraineeTableView.reloadData()
        }) { (err) in
            print(err.localizedDescription)
            self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
            return
        }
    }
    
    @IBAction func cancelBtnAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.editProfileBtn.setTitle("edit".localized(), for: .normal)
        self.heightTagLb.text = "height".localized()
        self.birthdayTagLb.text = "birthday".localized()
        self.weightTagLb.text = "weight".localized()
        self.reviewLb.text = "review".localized()
        
        self.reviewProfileTraineeTableView.tableFooterView = UIView()
        
        self.setupNavigationStyle()
        self.emailLb.textColor = UIColor.white.withAlphaComponent(0.4)
        self.editProfileBtn.isEnabled = false
        self.getTraineeProfile()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.review.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewProfileTraineeTableViewCell") as! ReviewProfileTraineeTableViewCell
        cell.profileImageView.downloaded(from: (self.trainerObj[self.review[indexPath.row].trainerUid]?.profileImageUrl)!)
        cell.profileImageView.accessibilityLabel = (self.trainerObj[self.review[indexPath.row].trainerUid]?.uid)!
        cell.profileImageView.addGestureRecognizer(UITapGestureRecognizer (target: self, action: #selector(trainerImgTapAction(tapGesture:))))
        cell.nameLb.text = self.trainerObj[self.review[indexPath.row].trainerUid]?.fullName
        cell.nameLb.accessibilityLabel = (self.trainerObj[self.review[indexPath.row].trainerUid]?.uid)!
        cell.nameLb.addGestureRecognizer(UITapGestureRecognizer (target: self, action: #selector(trainerImgTapAction(tapGesture:))))
        cell.ratingStackView.setStarsRating(rating: Int(self.review[indexPath.row].eachReiew[0].rating)!)
        cell.courseNameLb.text = self.courseObj[self.review[indexPath.row].courseId]?.course
        cell.reviewLb.text = self.review[indexPath.row].eachReiew[0].reviewDesc
        return cell
    }
    
    @objc func trainerImgTapAction(tapGesture: UITapGestureRecognizer) {
        
        var uid: String!
        if let tapImg = tapGesture.view as? UIImageView {
            uid = tapImg.accessibilityLabel
        } else if let tapLabel = tapGesture.view as? UILabel {
            uid = tapLabel.accessibilityLabel
        } else {
            return
        }
        performSegue(withIdentifier: "ProfileTraineeToProfileTrainer", sender: uid)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
        performSegue(withIdentifier: "ProfileToEachReview", sender: indexPath)
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset.y
        print(offset)
        
        if offset <= 170.0 {
            self.navigationController?.setNavigationBarHidden(true, animated: false)
        } else {
            self.navigationController?.setNavigationBarHidden(false, animated: false)
        }
    }
    
    func setProfileImageRound() {
        
        self.profileImageView.layer.masksToBounds = false
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.height / 2
        self.profileImageView.clipsToBounds = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProfileTraineeToEditProfileTrainee" {
            let vc = segue.destination as! UINavigationController
            let containVc = vc.topViewController as! EditProfileTraineeViewController
            containVc.traineeProfile = self.traineeProfile
        }
        if segue.identifier == "ProfileToEachReview" {
            guard let selectedIndexPath = sender as? IndexPath else { return }
            let vc = segue.destination as! UINavigationController
            let containVc = vc.topViewController as! FullReviewProfileViewController
            containVc.selectedFullReview = self.review[selectedIndexPath.row]
            containVc.selectedCourseName = self.courseObj[self.review[selectedIndexPath.row].courseId]?.course
            containVc.selectedProfileLink = self.trainerObj[self.review[selectedIndexPath.row].trainerUid]?.profileImageUrl
            containVc.selectedTraineeName = self.trainerObj[self.review[selectedIndexPath.row].trainerUid]?.fullName
            containVc.selectedProfileUid = self.trainerObj[self.review[selectedIndexPath.row].trainerUid]?.uid
            containVc.from = "trainee"
        }
        if segue.identifier == "ProfileTraineeToProfileTrainer" {
            
            guard let selectedTrainerForShowProfile = sender as? String else { return }
            let vc = segue.destination as! UINavigationController
            let containVc = vc.topViewController as! ProfileTrainerViewController
            containVc.isBlurProfileImage = false
            containVc.trainerProfileUid = selectedTrainerForShowProfile
        }
    }
    
    @IBAction func editProfileBtnAction(_ sender: UIButton) {
        performSegue(withIdentifier: "ProfileTraineeToEditProfileTrainee", sender: nil)
    }
    
    @IBAction func backBtnAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
