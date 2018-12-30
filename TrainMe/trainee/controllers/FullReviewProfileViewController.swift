//
//  EachReviewProfileViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 30/12/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit

class FullReviewProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var fullReviewTableView: UITableView!
    
    @IBOutlet weak var courseNameLb: UILabel!
    @IBOutlet weak var totalTimeLb: UILabel!
    
    var selectedFullReview: Review!
    var selectedCourseName: String!
    var selectedProfileLink: String!
    var selectedTraineeName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fullReviewTableView.delegate = self
        self.fullReviewTableView.dataSource = self
        
        self.courseNameLb.text = self.selectedCourseName
        self.totalTimeLb.text = "Total time of course: \(self.selectedFullReview.eachReiew.count) time"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FullReviewProfileTraineeTableViewCell") as! FullReviewTableViewCell
        if indexPath.row == 0 {
            cell.timeLb.text = "1 st Time"
        } else if indexPath.row == 1 {
            cell.timeLb.text = "2 nd Time"
        } else if indexPath.row == 2 {
            cell.timeLb.text = "3 rd Time"
        } else {
            cell.timeLb.text = "\(indexPath.row+1) th Time"
        }
        cell.profileImg.downloaded(from: self.selectedProfileLink)
        cell.nameLb.text = self.selectedTraineeName
        cell.ratingStackView.setStarsRating(rating: Int(self.selectedFullReview.eachReiew[indexPath.row].rating)!)
        cell.ratingStackView.isEnabled(isEnable: false)
        cell.reviewDescLb.text = self.selectedFullReview.eachReiew[indexPath.row].reviewDesc
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.selectedFullReview.eachReiew.count
    }
    
    @IBAction func cancelBtnAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupNavigationStyle()
    }
}
