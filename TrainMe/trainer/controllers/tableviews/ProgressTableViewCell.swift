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
    @IBOutlet weak var startDateLb: UILabel!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet weak var declineBtn: UIButton!
    
    func setDataToCell(traineeImgLink: String, traineeName: String, startDate: String, startTime: String, position: String) {
        
        self.traineeImg.downloaded(from: traineeImgLink)
        self.traineeNameLb.text = traineeName
        self.startDateLb.text = startDate
        self.startTime.text = startTime
        self.acceptBtn.accessibilityLabel = position
        self.declineBtn.accessibilityLabel = position
    }
    
    
    @IBAction func acceptBtnAction(_ sender: UIButton) {
        print(sender.accessibilityLabel)
    }
    
    @IBAction func declineBtnAction(_ sender: UIButton) {
        print(sender.accessibilityLabel)
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
