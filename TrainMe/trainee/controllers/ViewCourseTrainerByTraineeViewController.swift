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
    @IBOutlet weak var bookBtn: UIButton!
    
    var selectedBookDetail: BookPlaceDetail!
    
    var course: Course!
    var titleList: [String] = ["Name", "Detail", "Type", "Time", "Duration", "Level", "Price", "Language"]
    var descriptionList: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(course.getData())
        print(selectedBookDetail.getData())
        
        self.bookBtn.layer.cornerRadius = 17
        self.courseToList()
        self.courseDetailTableView.delegate = self
        self.courseDetailTableView.dataSource = self
    }
    
    func courseToList() {
        self.descriptionList = []
        self.descriptionList.append(course.course)
        self.descriptionList.append(course.courseContent)
        self.descriptionList.append(course.courseType)
        self.descriptionList.append(course.timeOfCourse)
        self.descriptionList.append(course.courseDuration)
        self.descriptionList.append(course.courseLevel)
        self.descriptionList.append(course.coursePrice)
        self.descriptionList.append(course.courseLanguage)
        self.courseDetailTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { 
        if(segue.identifier == "CourseDetailToNewProgress") {
            let vc = segue.destination as! UINavigationController
            let containVc = vc.topViewController as! NewProgressViewController
        }
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
    
    @IBAction func bookBtnAction(_ sender: UIButton) {
        performSegue(withIdentifier: "CourseDetailToNewProgress", sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupNavigationStyle()
    }
}
