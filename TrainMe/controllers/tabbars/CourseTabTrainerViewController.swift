//
//  CourseTabTrainerViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 26/8/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import SWRevealViewController
import FirebaseAuth
import FirebaseDatabase

class CourseTabTrainerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    var courses: [Course] = []
    var ref: DatabaseReference!
    var databaseHandle: DatabaseHandle!
    private var currentUser: User?
    
    func createCourse() {
        let course = Course(key: "a", course: "a", courseContent: "a", courseType: "a", timeOfCourse: "a", courseDuration: "a", courseLevel: "a", coursePrice: "a", courseLanguage: "a")
        courses.append(course)
    }
    
    @IBAction func AddButtonAction(_ sender: UIBarButtonItem) {
        
        self.performSegue(withIdentifier: "CourseToAddCourse", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createCourse()
        tableView.delegate = self
        tableView.dataSource = self
        
        currentUser = Auth.auth().currentUser
        
        initSideMenu()
        self.title = NSLocalizedString("course", comment: "")
        
        ref = Database.database().reference()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        getCourseData()
    }
    
    func getCourseData() {
        
        let userID = currentUser?.uid
        ref.child("courses").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.childrenCount > 0 {
                self.courses.removeAll()
                for courseObjs in snapshot.children.allObjects as! [DataSnapshot] {
                    let courseObj = courseObjs.value as? [String: AnyObject]
                    
                    let course = Course(key: courseObjs.key, course: courseObj?["course_name"] as! String, courseContent: courseObj?["course_content"] as! String, courseType: courseObj?["course_type"] as! String, timeOfCourse: courseObj?["time_of_course"] as! String, courseDuration: courseObj?["course_duration"] as! String, courseLevel: courseObj?["course_level"] as! String, coursePrice: courseObj?["course_price"] as! String, courseLanguage: courseObj?["course_language"] as! String)
                    self.courses.append(course)
                }
            }
            for i in self.courses{
                print(i.getData())
            }
        }) { (err) in
            print(err.localizedDescription)
            self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
            return
        }
        tableView.reloadData()
    }
    
    @IBAction func courseSegmentValueChanged(_ sender: CustomSegmentedControl) {
        print(sender.selectedSegmentIndex)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavigationStyle()
    }
    
    func initSideMenu() {
        
        if revealViewController() != nil {
            revealViewController().rearViewRevealWidth = 275
            self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            menuBtn.target = revealViewController()
            menuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(courses.count)
        return courses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let course = courses[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllCourseTrainerCell") as! AllCourseTrainerTableViewCell
        cell.setDataToTableViewCell(course: course)
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
