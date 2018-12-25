//
//  ProfileViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 8/10/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import ImageSlideshow

class ProfileTrainerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    

    @IBOutlet weak var profileTrainerTableView: UITableView!
    @IBOutlet weak var certificateImageSlideShow: ImageSlideshow!
    var trainerUid: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let localSource = [ImageSource(imageString: "menu")!, ImageSource(imageString: "star-filled")!]
        
        self.navigationController?.isNavigationBarHidden = true
        
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
        
        self.profileTrainerTableView.delegate = self
        self.profileTrainerTableView.dataSource = self
        
        print("nnn\(self.trainerUid)")
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
    
    @IBAction func cancelBtnAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}
