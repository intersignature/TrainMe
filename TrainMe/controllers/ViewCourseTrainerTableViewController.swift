//
//  ViewCourseTrainerTableViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 6/9/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ViewCourseTrainerTableViewController: UITableViewController{

    var course: Course = Course()
    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var contentLb: UILabel!
    @IBOutlet weak var typeLb: UILabel!
    @IBOutlet weak var timeOfCourseLb: UILabel!
    @IBOutlet weak var durationLb: UILabel!
    @IBOutlet weak var levelLb: UILabel!
    @IBOutlet weak var priceLb: UILabel!
    @IBOutlet weak var languageLb: UILabel!
    
    var currentUser: User?
    var ref: DatabaseReference!
    var courseKey: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLb.text = course.course
        contentLb.text = course.courseContent
        typeLb.text = course.courseType
        timeOfCourseLb.text = course.timeOfCourse
        durationLb.text = course.courseDuration
        levelLb.text = course.courseLevel
        priceLb.text = course.coursePrice
        languageLb.text = course.courseLanguage

        currentUser = Auth.auth().currentUser
        ref = Database.database().reference()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        getCourseData()
    }

    func getCourseData() {
        
        let userID = currentUser?.uid
        ref.child("courses").child(userID!).child(courseKey!).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            self.course = Course(key: snapshot.key, course: value?["course_name"] as? String ?? "", courseContent: value?["course_content"] as? String ?? "", courseType: value?["course_type"] as? String ?? "", timeOfCourse: value?["time_of_course"] as? String ?? "", courseDuration: value?["course_duration"] as? String ?? "", courseLevel: value?["course_level"] as? String ?? "", coursePrice: value?["course_price"] as? String ?? "", courseLanguage: value?["course_language"] as? String ?? "")
            self.nameLb.text = self.course.course
            self.contentLb.text = self.course.courseContent
            self.typeLb.text = self.course.courseType
            self.timeOfCourseLb.text = self.course.timeOfCourse
            self.durationLb.text = self.course.courseDuration
            self.levelLb.text = self.course.courseLevel
            self.priceLb.text = self.course.coursePrice
            self.languageLb.text = self.course.courseLanguage
            print(self.course.course+"fldsknjikfdji")
            
        }) { (err) in
            print(err.localizedDescription)
            self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
            return
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 8
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
