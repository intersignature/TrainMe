//
//  ViewCourseTrainerByTraineeViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 19/9/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ViewCourseTrainerByTraineeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var courseDetailTableView: UITableView!
    @IBOutlet weak var bookBtn: UIButton!
    
    var ref: DatabaseReference!
    var currentUser: User!
    
    var selectedBookDetail: BookPlaceDetail!
    
    var course: Course!
    var placeId: String!
    
    var titleList: [String] = ["Name", "Detail", "Type", "Time", "Duration", "Level", "Price", "Language"]
    var descriptionList: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(course.getData())
        print(selectedBookDetail.getData())
        
        self.ref = Database.database().reference()
        self.currentUser = Auth.auth().currentUser
        
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
            containVc.selectedBookDetail = self.selectedBookDetail
            containVc.selectedCourse = self.course
            containVc.selectedPlaceId = self.placeId
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
        let alert = UIAlertController(title: "Booking trainer", message: "trainer: \(self.selectedBookDetail.trainerId)\nCourse: \(self.course.course)\nPrice: \(self.course.coursePrice)", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) in
            self.view.showBlurLoader()
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            self.addPedndingDataToDatabase()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func addPedndingDataToDatabase() {
        
        let mainData = ["place_id": self.placeId,
                        "course_id": self.course.key,
                        "start_train_date": self.selectedBookDetail.startTrainDate,
                        "start_train_time": self.selectedBookDetail.startTrainTime,
                        "is_trainer_accept": "-1"]
        
        self.ref.child("pending_schedule_detail").child(self.selectedBookDetail.trainerId).child(self.selectedBookDetail.key).child(self.currentUser.uid).updateChildValues(mainData) { (err, ref) in
            if let err = err {
                self.view.removeBluerLoader()
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                print(err.localizedDescription)
                self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                return
            }
            self.view.removeBluerLoader()
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            let alert = UIAlertController(title: "Booking Successful", message: "", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) in
                
                self.performSegue(withIdentifier: "BookToFindTrainer", sender: self)
            }))
            self.present(alert, animated: true, completion: nil)
       
            print("aaaaa = \(self.selectedBookDetail.key)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupNavigationStyle()
    }
}
