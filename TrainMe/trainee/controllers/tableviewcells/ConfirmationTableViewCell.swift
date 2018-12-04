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
    @IBOutlet weak var courseName: UILabel!
    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var cancelBtn: UIButton!
    
    func setDataToCell(trainerProfileUrl: String, name: String, courseName: String, placeName: String, position: String) {
        
        self.trainerProfileImg.downloaded(from: trainerProfileUrl)
        self.nameLb.text = name
        self.courseName.text = courseName
        self.placeName.text = placeName
        self.cancelBtn.accessibilityLabel = position
        
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
