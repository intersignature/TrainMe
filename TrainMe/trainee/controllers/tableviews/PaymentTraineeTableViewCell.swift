//
//  PaymentTableViewCell.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 13/11/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit

class PaymentTraineeTableViewCell: UITableViewCell {

    @IBOutlet weak var trainerImg: UIImageView!
    @IBOutlet weak var trainerNameLb: UILabel!
    @IBOutlet weak var courseNameLb: UILabel!
    @IBOutlet weak var placeNameLb: UILabel!
    @IBOutlet weak var timeLb: UILabel!
    @IBOutlet weak var buyBtn: UIButton!
    
    func setDataToCell(trainerProfileUrl: String, name: String, courseName: String, placeName: String, time: String, position: String) {
        
        self.trainerImg.downloaded(from: trainerProfileUrl)
        self.trainerNameLb.text = name
        self.courseNameLb.text = courseName
        self.placeNameLb.text = placeName
        self.timeLb.text = time
        self.buyBtn.accessibilityLabel = position
        
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
