//
//  ReviewProfileTainerTableViewCell.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 26/12/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit

class ReviewProfileTainerTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var ratingStackView: RatingController!
    @IBOutlet weak var courseNameLb: UILabel!
    @IBOutlet weak var reviewDescLb: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setProfileImageRound()
    }

    func setProfileImageRound() {
        
        self.profileImageView.layer.masksToBounds = false
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.height/2
        self.profileImageView.clipsToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
