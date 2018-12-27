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

class ProfileTrainerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var profileTrainerTableView: UITableView!
    @IBOutlet weak var certificateImageSlideShow: ImageSlideshow!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var genderImageView: UIImageView!
    @IBOutlet weak var heightLb: UILabel!
    @IBOutlet weak var birthdayLb: UILabel!
    @IBOutlet weak var weightLb: UILabel!
    
    var ref: DatabaseReference!
    var currentUser: User!
    
    var trainerProfile: UserProfile!
    var localSource: [ImageSource]!
    var isBlurProfileImage: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ref = Database.database().reference()
        self.currentUser = Auth.auth().currentUser
        
        self.getTrainerProfile()
        
        localSource = [ImageSource(imageString: "menu")!, ImageSource(imageString: "star-filled")!]
        
        self.navigationController?.isNavigationBarHidden = true
        self.setProfileImageRound()
        self.profileImageView.isBlur(self.isBlurProfileImage)
        
        self.profileTrainerTableView.delegate = self
        self.profileTrainerTableView.dataSource = self
        self.setupImageSliderBar()
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
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewProfileTrainerTableViewCell") as! ReviewProfileTainerTableViewCell
        
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
    
    @IBAction func cancelBtnAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}
