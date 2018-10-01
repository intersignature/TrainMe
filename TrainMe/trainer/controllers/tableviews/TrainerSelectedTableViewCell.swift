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
    var time: [BookPlaceDetail] = []
    
    func setDataToCell(trainerProfile: UserProfile, tag: Int, time: [BookPlaceDetail]) {
        
        self.trainerImg.downloaded(from: trainerProfile.profileImageUrl)
        self.trainerImg.tag = tag
        self.trainerImg.isUserInteractionEnabled = true
        self.trainerNameLb.text = trainerProfile.fullName
        var timestr = ""
        time.forEach { (bookplace) in
            timestr += "\(bookplace.startTrainTime) "
        }
        self.trainerTime.text = "\(timestr)"
        self.time = time
        
        let tapGesture = UITapGestureRecognizer (target: self, action: #selector(imgTap(tapGesture:)))
        trainerImg.addGestureRecognizer(tapGesture)
    }
    
    @objc func imgTap(tapGesture: UITapGestureRecognizer) {
        let trainerTapImg = tapGesture.view as! UIImageView
        print(self.time[trainerTapImg.tag].trainerId)
    }
    
    func setProfileImageRound() {
        
//        self.trainerImg.layer.borderWidth = 10
        self.trainerImg.layer.masksToBounds = false
//        self.trainerImg.layer.borderColor = UIColor(red: 51/255.0, green: 51/255.0, blue: 153/255.0, alpha: 1).cgColor
        self.trainerImg.layer.cornerRadius = self.trainerImg.frame.height / 2
        self.trainerImg.clipsToBounds = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setProfileImageRound()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
