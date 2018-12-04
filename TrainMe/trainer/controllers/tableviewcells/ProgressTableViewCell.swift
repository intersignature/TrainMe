//
//  ProgressTableViewCell.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 24/10/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit

class ProgressTableViewCell: UITableViewCell {

    @IBOutlet weak var traineeImg: UIImageView!
    @IBOutlet weak var traineeNameLb: UILabel!
    @IBOutlet weak var courseName: UILabel!
    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet weak var declineBtn: UIButton!
    
    func setDataToCell(traineeImgLink: String, traineeName: String, courseName: String, placeName: String, position: String) {
        
        self.traineeImg.downloaded(from: traineeImgLink)
        self.traineeNameLb.text = traineeName
        self.courseName.text = courseName
        self.placeName.text = placeName
        self.acceptBtn.accessibilityLabel = position
        self.declineBtn.accessibilityLabel = position
        
        self.setProfileImageRound()
    }
    
    
    @IBAction func acceptBtnAction(_ sender: UIButton) {
//        print(sender.accessibilityLabel)
    }
    
    @IBAction func declineBtnAction(_ sender: UIButton) {
//        print(sender.accessibilityLabel)
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
