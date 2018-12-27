//
//  ProfileViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 8/10/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import ImageSlideshow
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class ProfileTrainerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var profileTrainerTableView: UITableView!
    @IBOutlet weak var certificateImageSlideShow: ImageSlideshow!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var genderImageView: UIImageView!
    @IBOutlet weak var heightLb: UILabel!
    @IBOutlet weak var birthdayLb: UILabel!
    @IBOutlet weak var weightLb: UILabel!
    @IBOutlet weak var reviewAndRatingCountLb: UILabel!
    @IBOutlet weak var fiveRatingCountLb: UILabel!
    @IBOutlet weak var fourRatingCountLb: UILabel!
    @IBOutlet weak var threeRatingCountLb: UILabel!
    @IBOutlet weak var twoRatingCountLb: UILabel!
    @IBOutlet weak var oneRatingCount: UILabel!
    @IBOutlet weak var fiveRatingProgressbar: UIProgressView!
    @IBOutlet weak var fourRatingProgressbar: UIProgressView!
    @IBOutlet weak var threeRatingProgressbar: UIProgressView!
    @IBOutlet weak var twoRatingProgressbar: UIProgressView!
    @IBOutlet weak var oneRatingProgressbar: UIProgressView!
    
    var ref: DatabaseReference!
    var storageRef: StorageReference!
    var currentUser: User!
    
    var trainerProfile: UserProfile!
    var localSource: [ImageSource] = []
    var review: [Review] = []
    var traineeObj: [String: UserProfile] = [:]
    var courseObj: [String: Course] = [:]
    var isBlurProfileImage: Bool!
    var rating: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ref = Database.database().reference()
        self.storageRef = Storage.storage().reference()
        self.currentUser = Auth.auth().currentUser
        
        self.getCertCount()
        self.getReviewData()
        self.getTrainerProfile()
        
        self.navigationController?.isNavigationBarHidden = true
        self.setProfileImageRound()
        self.profileImageView.isBlur(self.isBlurProfileImage)
        
        self.profileTrainerTableView.delegate = self
        self.profileTrainerTableView.dataSource = self
    }
    
    func setupImageSliderBar() {
        
        certificateImageSlideShow.slideshowInterval = 5.0
        certificateImageSlideShow.pageIndicatorPosition = .init(horizontal: .center, vertical: .under)
        certificateImageSlideShow.contentScaleMode = UIViewContentMode.scaleAspectFit
        
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = UIColor.lightGray
        pageControl.pageIndicatorTintColor = UIColor.black
        certificateImageSlideShow.pageIndicator = pageControl
        
        certificateImageSlideShow.activityIndicator = DefaultActivityIndicator()
        certificateImageSlideShow.currentPageChanged = { page in
            print("current page:", page)
        }
        
        certificateImageSlideShow.setImageInputs(localSource)
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        certificateImageSlideShow.addGestureRecognizer(recognizer)
    }
    
    func getTrainerProfile() {
        
        self.ref.child("user").child(self.currentUser.uid).observeSingleEvent(of: .value) { (snapshot) in
            
            let value = snapshot.value as! NSDictionary
            
            self.trainerProfile = UserProfile(fullName: (value["name"] as! String),
                                              email: (value["email"] as! String),
                                              dateOfBirth: (value["dateOfBirth"] as! String),
                                              weight: (value["weight"] as! String),
                                              height: (value["height"] as! String),
                                              gender: (value["gender"] as! String),
                                              role: (value["role"] as! String),
                                              profileImageUrl: (value["profileImageUrl"] as! String),
                                              uid: snapshot.key,
                                              omiseCusId: (value["omise_cus_id"] as! String))
            self.setDataToProfileView()
        }
    }
    
    func getCertCount() {
        
        self.ref.child("become_to_a_trainer").child(self.currentUser.uid).observeSingleEvent(of: .value) { (snapshot) in
            let value = snapshot.value as! NSDictionary
            print(value.count - 1)
            self.getCertImageFile(certCount: value.count - 1)
        }
    }
    
    func getCertImageFile(certCount: Int) {
        
        for i in 1...certCount {
            print("cert_\(i)")
            self.storageRef.child("BecomeToATrainer").child(self.currentUser.uid).child("certificate").child("cert_\(i).png").getData(maxSize: 30*1024*1024) { (data, err) in
                if let err = err {
                    self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                    print(err.localizedDescription)
                    return
                }
                let tempImageSource = ImageSource(image: UIImage(data: data!)!)
                self.localSource.append(tempImageSource)
                if self.localSource.count == certCount {
                    self.setupImageSliderBar()
                }
            }
        }
        
    }
    
    func getReviewData() {
        
        self.ref.child("progress_schedule_detail").child(self.currentUser.uid).observeSingleEvent(of: .value) { (snapshot) in
            
            let values = snapshot.value as? [String: [String: AnyObject]]
            values?.forEach({ (traineeId, overallScheduleDetail) in
                var allReview: [EachReview] = []
                overallScheduleDetail.forEach({ (btnKey, detail) in
                    allReview.removeAll()
                    let lastReviewDetail = detail[String(Int(detail.count)-4)] as! NSDictionary
                    print(lastReviewDetail)
                    if lastReviewDetail["status"] as! String == "2" {
                        if self.traineeObj[traineeId] == nil {
                            self.getTraineeData(traineeId: traineeId)
                        }
                        if self.courseObj[detail["course_id"] as! String] == nil {
                            self.getCourseObj(trainerId: self.currentUser.uid, courseId: detail["course_id"] as! String)
                        }
                        for i in 1...(Int(detail.count)-4){
                            let eachReviewValue = detail[String(i)] as? NSDictionary
                            let eachReview = EachReview(rating: eachReviewValue!["rate_point"] as! String,
                                                        reviewDesc: eachReviewValue!["review"] as! String)
//                            self.rating.append(eachReviewValue!["rate_point"] as! Int)
                            if let ratePoint = (eachReviewValue!["rate_point"] as? NSString)?.integerValue {
                                self.rating.append(ratePoint)
                            }
                            allReview.append(eachReview)
                        }
                        let tempReview = Review(traineeUid: traineeId,
                                                trainerUid: self.currentUser.uid,
                                                courseId: detail["course_id"] as! String,
                                                eachReview: allReview)
                        self.review.append(tempReview)
                        allReview.removeAll()
                    }
                    print(self.review)
                })
            })
            print("Rating\(self.rating)")
            self.setupReviewAndRatingView()
        }
    }
    
    func setupReviewAndRatingView() {
        
        var ratingScore = 0
        self.rating.forEach({ ratingScore += $0 })
        self.reviewAndRatingCountLb.text = "\(self.rating.count) Reviews (\(ratingScore) Rating)"
        
        var countsRatingDic = self.rating.reduce(into: [:]) { counts, rating in counts[rating, default: 0] += 1 }
        for i in 1...5 {
            print("dasasdas \(i)")
            if countsRatingDic[i] == nil {
                countsRatingDic[i] = 0
            }
        }
        self.fiveRatingCountLb.text = "\(countsRatingDic[5] ?? 0)"
        self.fourRatingCountLb.text = "\(countsRatingDic[4] ?? 0)"
        self.threeRatingCountLb.text = "\(countsRatingDic[3] ?? 0)"
        self.twoRatingCountLb.text = "\(countsRatingDic[2] ?? 0)"
        self.oneRatingCount.text = "\(countsRatingDic[1] ?? 0)"
        print("countsRatingDic \(countsRatingDic)")
        print("countsRatingDic \(self.rating.count)")
        
        var ratingInPercent: [Int: Float] = [:]
        countsRatingDic.forEach { (rating, count) in
            let dCount = Float(count)
            ratingInPercent[rating] = dCount/Float(self.rating.count)
        }
        self.fiveRatingProgressbar.progress = ratingInPercent[5]!
        self.fourRatingProgressbar.progress = ratingInPercent[4]!
        self.threeRatingProgressbar.progress = ratingInPercent[3]!
        self.twoRatingProgressbar.progress = ratingInPercent[2]!
        self.oneRatingProgressbar.progress = ratingInPercent[1]!
        print("countsRatingDic \(ratingInPercent)")
    }
    
    func getTraineeData(traineeId: String) {
        
        self.ref.child("user").child(traineeId).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as! NSDictionary
            self.traineeObj[traineeId] = UserProfile(fullName: (value["name"] as! String),
                                                     email: (value["email"] as! String),
                                                     dateOfBirth: (value["dateOfBirth"] as! String),
                                                     weight: (value["weight"] as! String),
                                                     height: (value["height"] as! String),
                                                     gender: (value["gender"] as! String),
                                                     role: (value["role"] as! String),
                                                     profileImageUrl: (value["profileImageUrl"] as! String),
                                                     omiseCusId: (value["omise_cus_id"] as! String))
            self.traineeObj[traineeId]?.uid = traineeId
            self.profileTrainerTableView.reloadData()
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
                                              courseType: value["course_type"] as! String,
                                              timeOfCourse: value["time_of_course"] as! String,
                                              courseDuration: value["course_duration"] as! String,
                                              courseLevel: value["course_level"] as! String,
                                              coursePrice: value["course_price"] as! String,
                                              courseLanguage: value["course_language"] as! String)
            self.profileTrainerTableView.reloadData()
        }) { (err) in
            print(err.localizedDescription)
            self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
            return
        }
    }
    
    func setDataToProfileView() {
        
        self.profileImageView.downloaded(from: self.trainerProfile.profileImageUrl)
        self.nameLb.text = self.trainerProfile.fullName
        if self.trainerProfile.gender == "male"{
            self.genderImageView.image = UIImage(named: "male")
        } else if self.trainerProfile.gender == "female" {
            self.genderImageView.image = UIImage(named: "female")
        }
        self.heightLb.text = "\(self.trainerProfile.height) cm"
        self.birthdayLb.text = "\(self.trainerProfile.dateOfBirth)"
        self.weightLb.text = "\(self.trainerProfile.weight) kg"
    }
    
    @objc func didTap() {
        let fullScreenController = certificateImageSlideShow.presentFullScreenController(from: self)

        fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .white, color: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.review.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewProfileTrainerTableViewCell") as! ReviewProfileTainerTableViewCell
        cell.profileImageView.downloaded(from: (self.traineeObj[self.review[indexPath.row].traineeUid]?.profileImageUrl)!)
        cell.nameLb.text = self.traineeObj[self.review[indexPath.row].traineeUid]?.fullName
        cell.ratingStackView.setStarsRating(rating: Int(self.review[indexPath.row].eachReiew[0].rating)!)
        cell.ratingStackView.isEnabled(isEnable: false)
        cell.courseNameLb.text = self.courseObj[self.review[indexPath.row].courseId]?.course
        cell.reviewDescLb.text = self.review[indexPath.row].eachReiew[0].reviewDesc
        return cell
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupNavigationStyle()
    }
    
    func setProfileImageRound() {
        
        self.profileImageView.layer.masksToBounds = false
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.height / 2
        self.profileImageView.clipsToBounds = true
    }
    
    @IBAction func backBtnAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelBtnAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}
