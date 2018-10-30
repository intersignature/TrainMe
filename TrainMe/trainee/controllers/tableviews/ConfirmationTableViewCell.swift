//
//  ConfirmationTableViewCell.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 30/10/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit

class ConfirmationTableViewCell: UITableViewCell {

    @IBOutlet weak var trainerProfileImg: UIImageView!
    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var startDate: UILabel!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var courseName: UILabel!
    @IBOutlet weak var placeName: UILabel!
    
    func setDataToCell(trainerProfileUrl: String, name: String, startDate: String, startTime: String, courseName: String, placeName: String) {
        
        self.trainerProfileImg.downloaded(from: trainerProfileUrl)
        self.nameLb.text = name
        self.startDate.text = startDate
        self.startTime.text = startTime
        self.courseName.text = courseName
        self.placeName.text = placeName
        
        self.setProfileImageRound()
    }
    
    func setProfileImageRound() {
        
        self.trainerProfileImg.layer.masksToBounds = false
        self.trainerProfileImg.layer.cornerRadius = self.trainerProfileImg.frame.height/2
        self.trainerProfileImg.clipsToBounds = true
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
