//
//  ShowCourseTrainerSpecifiedViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 15/9/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ShowCourseTrainerSpecifiedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var trainerId = ""
    var bookPlaceDetail: BookPlaceDetail!
    var selectedCourses = [Course]()
    var ref: DatabaseReference!
    var selectedCourseIndexPath: IndexPath!
    var placeId: String!
    
    @IBOutlet weak var selectedTrainerCourseTv: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.ref = Database.database().reference()
        self.trainerId = self.bookPlaceDetail.trainerId
        self.getSelectedTrainerCourses()
        print(self.trainerId)

        self.selectedTrainerCourseTv.delegate = self
        self.selectedTrainerCourseTv.dataSource = self
    }
    
    func getSelectedTrainerCourses() {
        
        ref.child("courses").child(trainerId).observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot.childrenCount)
            
            if snapshot.childrenCount > 0 {
                self.selectedCourses.removeAll()
                for courseObjs in snapshot.children.allObjects as! [DataSnapshot] {
                    let courseObj = courseObjs.value as? [String: AnyObject]
                    
                    let course = Course(key: courseObjs.key, course: courseObj?["course_name"] as! String, courseContent: courseObj?["course_content"] as! String, courseType: courseObj?["course_type"] as! String, timeOfCourse: courseObj?["time_of_course"] as! String, courseDuration: courseObj?["course_duration"] as! String, courseLevel: courseObj?["course_level"] as! String, coursePrice: courseObj?["course_price"] as! String, courseLanguage: courseObj?["course_language"] as! String)
                    self.selectedCourses.append(course)
                }
                self.selectedTrainerCourseTv.reloadData()
            }
            for i in self.selectedCourses{
                print(i.getData())
            }
        }) { (err) in
            print(err.localizedDescription)
            self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
            return
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedCourses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectedTrainerCourse") as! SelectedTrainerCourseTableViewCell
        
        cell.setDataToCell(course: selectedCourses.reversed()[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print(selectedCourses.reversed()[indexPath.row].getData())
        self.selectedCourseIndexPath = indexPath
        self.performSegue(withIdentifier: "SelectCourseToCourseDetail", sender: self)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let reportBtn = UITableViewRowAction(style: .normal, title: "Report") { (action, indexPath) in
            print(self.selectedCourses.reversed()[indexPath.row].getData())
        }
        reportBtn.backgroundColor = UIColor.orange
        
//        let viewBtn = UITableViewRowAction(style: .normal, title: "View") { (action, indexPath) in
//            //SelectCourseToCourseDetail
//            self.selectedCourseIndexPath = indexPath
//            self.performSegue(withIdentifier: "SelectCourseToCourseDetail", sender: self)
//        }
//        viewBtn.backgroundColor = UIColor.blue
//
        return [reportBtn]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "SelectCourseToCourseDetail") {
            let vc = segue.destination as! UINavigationController
            let containVc = vc.topViewController as! ViewCourseTrainerByTraineeViewController
            containVc.course = self.selectedCourses.reversed()[self.selectedCourseIndexPath.row]
            containVc.selectedBookDetail = self.bookPlaceDetail
            containVc.placeId = self.placeId
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.selectedTrainerCourseTv.tableFooterView = UIView()
        
        self.setupNavigationStyle()
    }
    @IBAction func backBtnAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}
