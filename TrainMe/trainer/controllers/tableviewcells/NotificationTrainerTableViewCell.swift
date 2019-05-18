//
//  NotificationTableViewCell.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 6/1/2562 BE.
//  Copyright © 2562 Sirichai Binchai. All rights reserved.
//

import UIKit

class NotificationTrainerTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var timeAgoLb: UILabel!
    @IBOutlet weak var descriptionLb: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setProfileImageRound()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setProfileImageRound() {
        
        self.profileImg.layer.masksToBounds = false
        self.profileImg.layer.cornerRadius = self.profileImg.frame.height/2
        self.profileImg.clipsToBounds = true
    }
}
