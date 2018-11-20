//
//  OngoingTraineeTableViewCell.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 20/11/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit

class OngoingTraineeTableViewCell: UITableViewCell {

    @IBOutlet weak var trainerImg: UIImageView!
    @IBOutlet weak var trainerNameLb: UILabel!
    @IBOutlet weak var courseNameLb: UILabel!
    @IBOutlet weak var timeLb: UILabel!
    @IBOutlet weak var scheduleDateLb: UILabel!
    @IBOutlet weak var placeNameLb: UILabel!
    
    
    func setDataToCell(trainerProfileUrl: String, trainerName: String, courseName: String, time: String, scheduleDate: String, placeName: String) {
        
        self.trainerImg.downloaded(from: trainerProfileUrl)
        self.trainerNameLb.text = trainerName
        self.courseNameLb.text = courseName
        self.timeLb.text = time
        self.scheduleDateLb.text = scheduleDate
        self.placeNameLb.text = placeName
        
        self.setProfileImageRound()
    }
    
    func setProfileImageRound() {
        
        self.trainerImg.layer.masksToBounds = false
        self.trainerImg.layer.cornerRadius = self.trainerImg.frame.height/2
        self.trainerImg.clipsToBounds = true
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
