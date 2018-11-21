//
//  OngoingTrainerTableViewCell.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 20/11/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit

class OngoingTrainerTableViewCell: UITableViewCell {

    @IBOutlet weak var traineeImg: UIImageView!
    @IBOutlet weak var traineeNameLb: UILabel!
    @IBOutlet weak var courseLb: UILabel!
    @IBOutlet weak var timeLb: UILabel!
    @IBOutlet weak var scheduleDateLb: UILabel!
    @IBOutlet weak var placeLb: UILabel!
    
    func setDataToCell(traineeImgUrl: String, traineeName: String, courseName: String, time: String, scheduleDate: String, place: String) {
        
        self.traineeImg.downloaded(from: traineeImgUrl)
        self.traineeNameLb.text = traineeName
        self.courseLb.text = courseName
        self.timeLb.text = time
        self.scheduleDateLb.text = scheduleDate
        self.placeLb.text = place
        
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
