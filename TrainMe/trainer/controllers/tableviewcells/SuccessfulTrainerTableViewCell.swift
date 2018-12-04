//
//  SuccessfulTrainerTableViewCell.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 22/11/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit

class SuccessfulTrainerTableViewCell: UITableViewCell {

    @IBOutlet weak var traineeImg: UIImageView!
    @IBOutlet weak var traineeLb: UILabel!
    @IBOutlet weak var courseLb: UILabel!
    @IBOutlet weak var placeLb: UILabel!
    @IBOutlet weak var dateLb: UILabel!
    
    func setDataToCell(traineeProfileUrl: String, traineeName: String, courseName: String, place: String, date: String) {
        
        self.traineeImg.downloaded(from: traineeProfileUrl)
        self.traineeLb.text = traineeName
        self.courseLb.text = courseName
        self.placeLb.text = place
        self.dateLb.text = date
        
        self.setProfileImageRound()
    }
    
    func setProfileImageRound() {
        
        self.traineeImg.layer.masksToBounds = false
        self.traineeImg.layer.cornerRadius = self.traineeImg.frame.height/2
        self.traineeImg.clipsToBounds = true
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
