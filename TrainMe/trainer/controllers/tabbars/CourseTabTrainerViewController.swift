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
    var selectedCourse: Course = Course()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        currentUser = Auth.auth().currentUser
        getCourseData()
        initSideMenu()

        let editCourseBtn = UIBarButtonItem(title: "edit".localized(), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.setTableViewEditingMode(_:)))
        editCourseBtn.tintColor = UIColor.white
        let addCourseBtn = UIBarButtonItem(title: "add".localized(), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.showAddCoursePage))
        addCourseBtn.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItems = [editCourseBtn, addCourseBtn]
    }
    
    @objc func setTableViewEditingMode(_ sender: UIBarButtonItem) {
        
        tableView.setEditing(!tableView.isEditing, animated: true)
        navigationItem.rightBarButtonItem?.title = tableView.isEditing ? "done".localized() : "edit".localized()
    }
    
    @objc func showAddCoursePage() {
        
        self.performSegue(withIdentifier: "CourseToAddCourse", sender: nil)
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
                    
                    let course = Course(key: courseObjs.key,
                                        course: courseObj?["course_name"] as! String,
                                        courseContent: courseObj?["course_content"] as! String,
                                        courseVideoUrl: courseObj?["course_video_url"] as! String,
                                        courseType: courseObj?["course_type"] as! String,
                                        timeOfCourse: courseObj?["time_of_course"] as! String,
                                        courseDuration: courseObj?["course_duration"] as! String,
                                        courseLevel: courseObj?["course_level"] as! String,
                                        coursePrice: courseObj?["course_price"] as! String,
                                        courseLanguage: courseObj?["course_language"] as! String,
                                        isDelete: courseObj?["is_delete"] as! String)
                    
                    if course.isDelete == "0" {
                        self.courses.insert(course, at: 0)
                    }
                }
                self.tableView.reloadData()
            }
            for i in self.courses{
                print(i.getData())
            }
        }) { (err) in
            print(err.localizedDescription)
            self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
            return
        }
    }
    
    @IBAction func courseSegmentValueChanged(_ sender: CustomSegmentedControl) {
        print(sender.selectedSegmentIndex)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.tableFooterView = UIView()
        
        title = "course".localized()
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "CourseToViewCourseTrainer") {
            let vc = segue.destination as! UINavigationController
            let containVc = vc.topViewController as! ViewCourseTrainerViewController
            containVc.course = selectedCourse
        }
        if segue.identifier == "ViewCourseToEditCourse" {
            let vc = segue.destination as! UINavigationController
            let containVc = vc.topViewController as! EditCourseViewController
            containVc.course = selectedCourse
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCourse = courses[indexPath.row]
        print(courses[indexPath.row].course)
        performSegue(withIdentifier: "CourseToViewCourseTrainer", sender: self)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteBtn = UITableViewRowAction(style: .destructive, title: "delete".localized()) { (action, indexPath) in
            let chooseAlert = UIAlertController(title: "", message: "would_you_like_to_delete_this_course".localized(), preferredStyle: .actionSheet)
            chooseAlert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil))
            chooseAlert.addAction(UIAlertAction(title: "delete".localized(), style: .destructive, handler: { (action) in
                self.deleteCourseInFirebase(indexPath: indexPath)
                self.courses.remove(at: indexPath.row)
                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: .automatic)
                tableView.endUpdates()
            }))
            self.present(chooseAlert, animated: true)
        }
        
        let editBtn = UITableViewRowAction(style: .normal, title: "edit".localized()) { (action, indexPath) in
            self.selectedCourse = self.courses[indexPath.row]
            self.performSegue(withIdentifier: "ViewCourseToEditCourse", sender: self)
            print("Edit at \(indexPath.row)")
        }
        
        editBtn.backgroundColor = UIColor.blue
        return [editBtn, deleteBtn]
    }
    
    func deleteCourseInFirebase(indexPath: IndexPath) {
        print("deleteCourseInFirebase")
        let uid = currentUser?.uid
        let changeVal = ["is_delete": "1"]
        
        self.ref.child("courses").child(uid!).child(courses[indexPath.row].key).updateChildValues(changeVal) { (err, ref) in
            if let err = err {
                self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
            }
            self.createAlert(alertTitle: "delete_course_successfully".localized(), alertMessage: "")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
