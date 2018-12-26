//
//  ReviewProfileTraineeTableViewCell.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 23/12/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit

class ReviewProfileTraineeTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var ratingStackView: RatingController!
    @IBOutlet weak var courseNameLb: UILabel!
    @IBOutlet weak var reviewLb: UILabel!
    
    func setProfileImageRound() {
        
        self.profileImageView.layer.masksToBounds = false
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.height / 2
        self.profileImageView.clipsToBounds = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.ratingStackView.isEnabled(isEnable: false)
        self.setProfileImageRound()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
