//
//  TrainerSelectedTableViewCell.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 12/9/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit

class TrainerSelectedTableViewCell: UITableViewCell {

    @IBOutlet weak var trainerImg: UIImageView!
    @IBOutlet weak var trainerNameLb: UILabel!
    @IBOutlet weak var trainerTime: UILabel!
    
    func setDataToCell(trainerProfile: UserProfile) {
        
        if trainerProfile.profileImageUrl != "" && trainerProfile.profileImageUrl != "-1" {
            self.trainerImg.downloaded(from: trainerProfile.profileImageUrl)
            self.trainerImg.layer.cornerRadius = self.trainerImg.frame.height / 2
            self.setProfileImageRound()
        }
        self.trainerNameLb.text = trainerProfile.fullName
        self.trainerTime.text = "dsfsdfdsfsdfsdf"
    }
    
    func setProfileImageRound() {
        
//        self.trainerImg.layer.borderWidth = 10
        self.trainerImg.layer.masksToBounds = false
//        self.trainerImg.layer.borderColor = UIColor(red: 51/255.0, green: 51/255.0, blue: 153/255.0, alpha: 1).cgColor
        self.trainerImg.layer.cornerRadius = self.trainerImg.frame.height/2
        self.trainerImg.clipsToBounds = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.trainerImg.layer.cornerRadius = 17
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
