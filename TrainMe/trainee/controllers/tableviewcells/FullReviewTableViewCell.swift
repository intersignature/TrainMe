//
//  FullReviewTableViewCell.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 30/12/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import ExpandableLabel

class FullReviewTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLb: UILabel!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var ratingStackView: RatingController!
    @IBOutlet weak var reviewDescLb: ExpandableLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setProfileImageRound()
        self.reviewDescLb.collapsed = true
    }
    
    func setProfileImageRound() {
        
        self.profileImg.layer.masksToBounds = false
        self.profileImg.layer.cornerRadius = self.profileImg.frame.height/2
        self.profileImg.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
