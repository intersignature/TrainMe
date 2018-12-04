//
//  CourseDetailTableViewCell.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 9/9/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit

class CourseDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLb: UILabel!
    @IBOutlet weak var descriptionLb: UILabel!
    
    func setCourseDetail(title: String, description: String) {
        titleLb.text = title
        descriptionLb.text = description
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
