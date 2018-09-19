//
//  ViewCourseTrainerByTraineeViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 19/9/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit

class ViewCourseTrainerByTraineeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var courseDetailTableView: UITableView!
    var course: Course!
    var titleList: [String] = ["Name", "Detail", "Type", "Time", "Duration", "Level", "Price", "Language"]
    var descriptionList: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(course.getData())
        
        self.courseToList()
        self.courseDetailTableView.delegate = self
        self.courseDetailTableView.dataSource = self
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CourseDetailByTraineeTableViewCell") as! CourseDetailTableViewCell
        
        cell.setCourseDetail(title: titleList[indexPath.row], description: descriptionList[indexPath.row])
        
        return cell
    }
    
    @IBAction func backBtnAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupNavigationStyle()
    }
}
