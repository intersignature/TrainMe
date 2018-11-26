//
//  SelectedTrainerCourseTableViewCell.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 15/9/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit

class SelectedTrainerCourseTableViewCell: UITableViewCell {

    @IBOutlet weak var courseNameLb: UILabel!
    @IBOutlet weak var priceLb: UILabel!

    func setDataToCell(course: Course) {
        self.courseNameLb.text = course.course
        self.priceLb.text = "\(course.coursePrice) Bath"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
