//
//  ViewCourseTrainerViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 6/9/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit

class ViewCourseTrainerViewController: UIViewController {

    var course:Course = Course()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(course.courseLevel)
        // Do any additional setup after loading the view.
    }

    @IBAction func editBtnAction(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: "ViewCourseTrainerToEditCourseTrainer", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ViewCourseTableViewEmbed") {
            let childViewController = segue.destination as! ViewCourseTrainerTableViewController
            childViewController.course = course
        }
        if(segue.identifier == "ViewCourseTrainerToEditCourseTrainer") {
            let vc = segue.destination as! UINavigationController
            let containVc = vc.topViewController as! EditCourseViewController
            containVc.course = course
        }
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
