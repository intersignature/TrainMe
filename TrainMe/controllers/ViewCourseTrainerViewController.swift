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

class ViewCourseTrainerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var courseDetailTableView: UITableView!
    
    var course:Course = Course()
    var titleList: [String] = ["Name", "Detail", "Type", "Time", "Duration", "Level", "Price", "Language"]
    var descriptionList:[String] = []
    var currentUser: User?
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentUser = Auth.auth().currentUser
        ref = Database.database().reference()
        courseToList()
        courseDetailTableView.delegate = self
        courseDetailTableView.dataSource = self
        // Do any additional setup after loading the view.
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

    @IBAction func editBtnAction(_ sender: UIBarButtonItem) {
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "CourseDetailTableViewCell") as! CourseDetailTableViewCell
        
        cell.setCourseDetail(title: titleList[indexPath.row], description: descriptionList[indexPath.row])
        
        return cell
    }
    
    func getCourseData() {
        
        let userID = currentUser?.uid
        ref.child("courses").child(userID!).child(course.key).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            self.course = Course(key: snapshot.key, course: value?["course_name"] as? String ?? "", courseContent: value?["course_content"] as? String ?? "", courseType: value?["course_type"] as? String ?? "", timeOfCourse: value?["time_of_course"] as? String ?? "", courseDuration: value?["course_duration"] as? String ?? "", courseLevel: value?["course_level"] as? String ?? "", coursePrice: value?["course_price"] as? String ?? "", courseLanguage: value?["course_language"] as? String ?? "")
            self.courseToList()
            print(self.course.course+"fldsknjikfdji")
            
        }) { (err) in
            print(err.localizedDescription)
            self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
            return
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getCourseData()
        
        
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
        setupNavigationStyle()
       
    }
}
