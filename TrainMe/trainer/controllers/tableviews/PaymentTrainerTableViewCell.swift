//
//  PaymentTrainerTableViewCell.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 13/11/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit

class PaymentTrainerTableViewCell: UITableViewCell {

    @IBOutlet weak var traineeImg: UIImageView!
    @IBOutlet weak var traineeNameLb: UILabel!
    @IBOutlet weak var courseNameLb: UILabel!
    @IBOutlet weak var placeNameLb: UILabel!
    @IBOutlet weak var timeLb: UILabel!
    
    func setData(traineeImgLink: String, traineeName: String, courseName: String, placeName: String, time: String) {
        
        self.traineeImg.downloaded(from: traineeImgLink)
        self.traineeNameLb.text = traineeName
        self.courseNameLb.text = courseName
        self.placeNameLb.text = placeName
        self.timeLb.text = time
        
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
