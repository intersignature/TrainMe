//
//  AllCourseTrainerTableViewCell.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 5/9/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit

class AllCourseTrainerTableViewCell: UITableViewCell {

    @IBOutlet weak var courseNameLb: UILabel!
    @IBOutlet weak var courseDetail: UILabel!
    @IBOutlet weak var timeOfCourseLb: UILabel!
    
    func setDataToTableViewCell(course: Course) {
        courseNameLb.text = course.course
        courseDetail.text = course.courseContent
        timeOfCourseLb.text = "\(course.timeOfCourse) times"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        courseNameLb.showAnimatedSkeleton()
//        courseDetail.showAnimatedSkeleton()
//        timeOfCourseLb.showAnimatedSkeleton()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
