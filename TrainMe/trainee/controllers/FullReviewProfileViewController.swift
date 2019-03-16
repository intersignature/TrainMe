//
//  EachReviewProfileViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 30/12/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import ExpandableLabel
import Localize_Swift

class FullReviewProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ExpandableLabelDelegate {
    
    @IBOutlet weak var fullReviewTableView: UITableView!
    
    @IBOutlet weak var courseNameLb: UILabel!
    @IBOutlet weak var totalTimeLb: UILabel!
    
    var from: String!
    var selectedFullReview: Review!
    var selectedProfileUid: String!
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
        self.totalTimeLb.text = "\("total_time_of_course".localized()): \(self.selectedFullReview.eachReiew.count) \("times".localized())"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        fullReviewTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let currentSource = reviewDescArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "FullReviewProfileTraineeTableViewCell") as! FullReviewTableViewCell
        if indexPath.row == 0 {
            if Localize.currentLanguage() == "th" {
                cell.timeLb.text = "ครั้งที่ 1"
            } else {
                cell.timeLb.text = "1 st Time"
            }
        } else if indexPath.row == 1 {
            if Localize.currentLanguage() == "th" {
                cell.timeLb.text = "ครั้งที่ 2"
            } else {
                cell.timeLb.text = "2 nd Time"
            }
        } else if indexPath.row == 2 {
            if Localize.currentLanguage() == "th" {
                cell.timeLb.text = "ครั้งที่ 3"
            } else {
                cell.timeLb.text = "3 rd Time"
            }
        } else {
            if Localize.currentLanguage() == "th" {
                cell.timeLb.text = "ครั้งที่ \(indexPath.row+1)"
            } else {
                cell.timeLb.text = "\(indexPath.row+1) th Time"
            }
        }
        cell.profileImg.accessibilityLabel = self.selectedProfileUid
        cell.profileImg.downloaded(from: self.selectedProfileLink)
        cell.profileImg.addGestureRecognizer(UITapGestureRecognizer (target: self, action: #selector(traineeImgTapAction(tapGesture:))))
        cell.nameLb.accessibilityLabel = self.selectedProfileUid
        cell.nameLb.text = self.selectedTraineeName
        cell.nameLb.addGestureRecognizer(UITapGestureRecognizer (target: self, action: #selector(traineeImgTapAction(tapGesture:))))
        cell.ratingStackView.setStarsRating(rating: Int(self.selectedFullReview.eachReiew[indexPath.row].rating)!)
        cell.ratingStackView.isEnabled(isEnable: false)
//        cell.reviewDescLb.text = self.selectedFullReview.eachReiew[indexPath.row].reviewDesc
        cell.reviewDescLb.delegate = self
        cell.reviewDescLb.setLessLinkWith(lessLink: "close".localized(), attributes: [.foregroundColor:UIColor.red], position: nil)
        cell.reviewDescLb.collapsedAttributedLink = NSAttributedString(string: "more".localized())
        cell.layoutIfNeeded()
        cell.reviewDescLb.shouldCollapse = true
        cell.reviewDescLb.textReplacementType = currentSource.textReplacementType
        cell.reviewDescLb.numberOfLines = currentSource.numberOfLines
        cell.reviewDescLb.collapsed = states[indexPath.row]
        cell.reviewDescLb.text = currentSource.text
        
        return cell
    }
    
    @objc func traineeImgTapAction(tapGesture: UITapGestureRecognizer) {
        
        var uid: String!
        if let tapImg = tapGesture.view as? UIImageView {
            uid = tapImg.accessibilityLabel
        } else if let tapLabel = tapGesture.view as? UILabel {
            uid = tapLabel.accessibilityLabel
        } else {
            return
        }
        if from == "trainer" {
            performSegue(withIdentifier: "FullReviewToProfileTrainee", sender: uid)
        } else if from == "trainee"{
            performSegue(withIdentifier: "FullReviewToProfileTrainer", sender: uid)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "FullReviewToProfileTrainee" {
            
            guard let selectedTrainerForShowProfile = sender as? String else { return }
            let vc = segue.destination as! UINavigationController
            let containVc = vc.topViewController as! ProfileTraineeViewController
            containVc.isBlurProfile = false
            containVc.traineeProfileUid = selectedTrainerForShowProfile
        }
        if segue.identifier == "FullReviewToProfileTrainer" {
            guard let selectedTrainerForShowProfile = sender as? String else { return }
            let vc = segue.destination as! UINavigationController
            let containVc = vc.topViewController as! ProfileTrainerViewController
            containVc.isBlurProfileImage = true
            containVc.trainerProfileUid = selectedTrainerForShowProfile
        }
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
        
        self.fullReviewTableView.tableFooterView = UIView()
        
        self.title = "full_review".localized()
        
        self.setupNavigationStyle()
        self.preparedSources()
    }
}
