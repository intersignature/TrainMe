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
    
    @IBAction func AddButtonAction(_ sender: UIBarButtonItem) {
        
        self.performSegue(withIdentifier: "CourseToAddCourse", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        currentUser = Auth.auth().currentUser
        getCourseData()
        initSideMenu()
        self.title = NSLocalizedString("course", comment: "")
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
//
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//
//
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//
//        if editingStyle == .delete {
//
//            let chooseAlert = UIAlertController(title: "", message: "Would you like to delete this course?", preferredStyle: .actionSheet)
//            chooseAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//            chooseAlert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
//                self.deleteCourseInFirebase(indexPath: indexPath)
//                self.courses.remove(at: indexPath.row)
//                tableView.beginUpdates()
//                tableView.deleteRows(at: [indexPath], with: .automatic)
//                tableView.endUpdates()
//            }))
//            self.present(chooseAlert, animated: true)
//        }
//    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteBtn = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            let chooseAlert = UIAlertController(title: "", message: "Would you like to delete this course?", preferredStyle: .actionSheet)
            chooseAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            chooseAlert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                self.deleteCourseInFirebase(indexPath: indexPath)
                self.courses.remove(at: indexPath.row)
                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: .automatic)
                tableView.endUpdates()
            }))
            self.present(chooseAlert, animated: true)
        }
        
        let editBtn = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
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
        
        self.ref.child("courses").child(uid!).child(courses[indexPath.row].key).removeValue { (err, ref) in
            print(err?.localizedDescription)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
