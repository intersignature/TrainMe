//
//  SuccessfulTraineeTableViewCell.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 22/11/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit

class SuccessfulTraineeTableViewCell: UITableViewCell {

    @IBOutlet weak var trainerImg: UIImageView!
    @IBOutlet weak var trainerNameLb: UILabel!
    @IBOutlet weak var courseNameLb: UILabel!
    @IBOutlet weak var placeNameLb: UILabel!
    @IBOutlet weak var timeLb: UILabel!
    
    func setDataToCell(trainerProfileUrl: String, trainerName: String, courseName: String, placeName: String, time: String) {
        
        self.trainerImg.downloaded(from: trainerProfileUrl)
        self.trainerNameLb.text = trainerName
        self.courseNameLb.text = courseName
        self.placeNameLb.text = placeName
        self.timeLb.text = time
        
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
