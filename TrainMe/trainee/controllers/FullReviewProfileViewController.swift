//
//  EachReviewProfileViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 30/12/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import ExpandableLabel

class FullReviewProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ExpandableLabelDelegate {
    
    @IBOutlet weak var fullReviewTableView: UITableView!
    
    @IBOutlet weak var courseNameLb: UILabel!
    @IBOutlet weak var totalTimeLb: UILabel!
    
    var selectedFullReview: Review!
    var selectedCourseName: String!
    var selectedProfileLink: String!
    var selectedTraineeName: String!
    var states : Array<Bool>!
    var reviewDescArray: [(text: String, textReplacementType: ExpandableLabel.TextReplacementType, numberOfLines: Int, textAlignment: NSTextAlignment)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        states = [Bool](repeating: true, count: self.selectedFullReview.eachReiew.count)
        self.fullReviewTableView.delegate = self
        self.fullReviewTableView.dataSource = self
        self.fullReviewTableView.estimatedRowHeight = 44
        self.fullReviewTableView.rowHeight = UITableViewAutomaticDimension
        
        self.courseNameLb.text = self.selectedCourseName
        self.totalTimeLb.text = "Total time of course: \(self.selectedFullReview.eachReiew.count) time"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        fullReviewTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let currentSource = reviewDescArray[indexPath.row]
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
//        cell.reviewDescLb.text = self.selectedFullReview.eachReiew[indexPath.row].reviewDesc
        cell.reviewDescLb.delegate = self
        cell.reviewDescLb.setLessLinkWith(lessLink: "Close", attributes: [.foregroundColor:UIColor.red], position: nil)
        cell.layoutIfNeeded()
        cell.reviewDescLb.shouldCollapse = true
        cell.reviewDescLb.textReplacementType = currentSource.textReplacementType
        cell.reviewDescLb.numberOfLines = currentSource.numberOfLines
        cell.reviewDescLb.collapsed = states[indexPath.row]
        cell.reviewDescLb.text = currentSource.text
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.selectedFullReview.eachReiew.count
    }
    
    func preparedSources() {
        
        self.selectedFullReview.eachReiew.forEach { (eachReview) in
            reviewDescArray.append((text: eachReview.reviewDesc, textReplacementType: .word, numberOfLines: 3, textAlignment: .center))
        }
    }
    
    func willExpandLabel(_ label: ExpandableLabel) {
        fullReviewTableView.beginUpdates()
    }
    
    func didExpandLabel(_ label: ExpandableLabel) {
        let point = label.convert(CGPoint.zero, to: fullReviewTableView)
        if let indexPath = self.fullReviewTableView.indexPathForRow(at: point) as IndexPath? {
            states[indexPath.row] = false
            DispatchQueue.main.async { [weak self] in
                self?.fullReviewTableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
        }
        fullReviewTableView.endUpdates()
    }
    
    func willCollapseLabel(_ label: ExpandableLabel) {
        fullReviewTableView.beginUpdates()
    }
    
    func didCollapseLabel(_ label: ExpandableLabel) {
        let point = label.convert(CGPoint.zero, to: fullReviewTableView)
        if let indexPath = self.fullReviewTableView.indexPathForRow(at: point) as IndexPath? {
            states[indexPath.row] = true
            DispatchQueue.main.async { [weak self] in
                self?.fullReviewTableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
        }
        fullReviewTableView.endUpdates()
    }
    
    @IBAction func cancelBtnAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupNavigationStyle()
        self.preparedSources()
    }
}
