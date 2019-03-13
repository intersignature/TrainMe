//
//  ViewCourseTrainerViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 6/9/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import ExpandableLabel

class ViewCourseTrainerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ExpandableLabelDelegate {
    
    @IBOutlet weak var courseDetailTableView: UITableView!
    
    var course:Course = Course()
    var titleList: [String] = ["name_course".localized(),
                               "course_content".localized(),
                               "course_type".localized(),
                               "time_of_course".localized(),
                               "course_duration".localized(),
                               "course_level".localized(),
                               "course_price".localized(),
                               "course_language".localized()]
    var descriptionList:[String] = []
    var currentUser: User?
    var ref: DatabaseReference!
    
    var states : Array<Bool>!
    var courseDescArray: [(text: String, textReplacementType: ExpandableLabel.TextReplacementType, numberOfLines: Int, textAlignment: NSTextAlignment)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let editCourseBtn = UIBarButtonItem(title: "edit".localized(), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.editBtnAction(_:)))
        editCourseBtn.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItems = [editCourseBtn]
        
        states = [Bool](repeating: true, count: self.titleList.count)
        
        self.ref = Database.database().reference()
        self.currentUser = Auth.auth().currentUser
        
        self.courseToList()
        self.courseDetailTableView.delegate = self
        self.courseDetailTableView.dataSource = self
        self.courseDetailTableView.estimatedRowHeight = 44
        self.courseDetailTableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func courseToList() {
        
        descriptionList = []
        descriptionList.append(course.course)
        descriptionList.append(course.courseContent)
        descriptionList.append(course.courseType)
        descriptionList.append(course.timeOfCourse)
        descriptionList.append(course.courseDuration)
        descriptionList.append(course.courseLevel)
        descriptionList.append(course.coursePrice)
        descriptionList.append(course.courseLanguage)
        self.courseDetailTableView.reloadData()
    }

    @objc func editBtnAction(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: "ViewCourseTrainerToEditCourseTrainer", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "ViewCourseTrainerToEditCourseTrainer") {
            let vc = segue.destination as! UINavigationController
            let containVc = vc.topViewController as! EditCourseViewController
            containVc.course = course
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let currentSource = courseDescArray[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CourseDetailTableViewCell") as! CourseDetailTableViewCell
        
//        cell.setCourseDetail(title: titleList[indexPath.row], description: descriptionList[indexPath.row])
        cell.titleLb.text = titleList[indexPath.row]
        cell.descriptionLb.delegate = self
        cell.descriptionLb.setLessLinkWith(lessLink: "close".localized(), attributes: [.foregroundColor:UIColor.red], position: nil)
        cell.layoutIfNeeded()
        cell.descriptionLb.shouldCollapse = true
        cell.descriptionLb.textReplacementType = currentSource.textReplacementType
        cell.descriptionLb.numberOfLines = currentSource.numberOfLines
        cell.descriptionLb.collapsed = states[indexPath.row]
        cell.descriptionLb.text = currentSource.text
        cell.descriptionLb.collapsedAttributedLink = NSAttributedString(string: "more".localized())
        
        return cell
    }
    
    func preparedSources() {
        
        self.descriptionList.forEach { (desc) in
            courseDescArray.append((text: desc, textReplacementType: .word, numberOfLines: 3, textAlignment: .right))
        }
    }
    
    func willExpandLabel(_ label: ExpandableLabel) {
        courseDetailTableView.beginUpdates()
    }
    
    func didExpandLabel(_ label: ExpandableLabel) {
        let point = label.convert(CGPoint.zero, to: courseDetailTableView)
        if let indexPath = self.courseDetailTableView.indexPathForRow(at: point) as IndexPath? {
            states[indexPath.row] = false
            DispatchQueue.main.async { [weak self] in
                self?.courseDetailTableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
        }
        courseDetailTableView.endUpdates()
    }
    
    func willCollapseLabel(_ label: ExpandableLabel) {
        courseDetailTableView.beginUpdates()
    }
    
    func didCollapseLabel(_ label: ExpandableLabel) {
        let point = label.convert(CGPoint.zero, to: courseDetailTableView)
        if let indexPath = self.courseDetailTableView.indexPathForRow(at: point) as IndexPath? {
            states[indexPath.row] = true
            DispatchQueue.main.async { [weak self] in
                self?.courseDetailTableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
        }
        courseDetailTableView.endUpdates()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.courseDetailTableView.reloadData()
        
//        self.performSegue(withIdentifier: "ViewCourseTableViewEmbed", sender: self)
    }

    @IBAction func backBtnAction(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        setupNavigationStyle()
        
        title = "course_detail".localized()
        
        self.courseDetailTableView.tableFooterView = UIView()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        self.preparedSources()
    }
}
