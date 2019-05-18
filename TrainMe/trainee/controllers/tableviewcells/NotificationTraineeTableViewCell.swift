//
//  NotificationTraineeTableViewCell.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 2/5/2562 BE.
//  Copyright © 2562 Sirichai Binchai. All rights reserved.
//

import UIKit

class NotificationTraineeTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var timeAgoLb: UILabel!
    @IBOutlet weak var descriptionLb: UILabel!
    @IBOutlet weak var reportBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.setProfileImageRound()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setProfileImageRound() {
        
        self.profileImg.layer.masksToBounds = false
        self.profileImg.layer.cornerRadius = self.profileImg.frame.height/2
        self.profileImg.clipsToBounds = true
    }
}
