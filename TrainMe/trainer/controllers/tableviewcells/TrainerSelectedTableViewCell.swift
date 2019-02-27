//
//  TrainerSelectedTableViewCell.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 12/9/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit

protocol BookDetailValueDelegate {
    
    func didRecieveValue(bookPlaceDetailTapObject: BookPlaceDetail)
}

class TrainerSelectedTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate, TimeButtonCollectionCellDelegate {
    
    func didTapTimeButoon(bookPlaceDetailTapObject: BookPlaceDetail) {

        self.delegate?.didRecieveValue(bookPlaceDetailTapObject: bookPlaceDetailTapObject)
    }

    @IBOutlet weak var trainerImg: UIImageView!
    @IBOutlet weak var trainerNameLb: UILabel!
    @IBOutlet weak var timeCollect: UICollectionView!
    var delegate: BookDetailValueDelegate?
    var trainerNo: Int!
    var buttonIdPendingAlready: [String] = []
    
    var time: [BookPlaceDetail] = []
    
    func setDataToCell(trainerProfile: UserProfile, tag: Int, time: [BookPlaceDetail], buttonIdPendingAlready: [String]) {
        
        self.trainerNo = tag
        self.trainerImg.downloaded(from: trainerProfile.profileImageUrl)
        self.trainerImg.tag = tag
        self.trainerImg.accessibilityLabel = trainerProfile.uid
        self.trainerNameLb.text = trainerProfile.fullName
        self.trainerNameLb.accessibilityLabel = trainerProfile.uid
        self.buttonIdPendingAlready = buttonIdPendingAlready
        var timestr = ""
        time.forEach { (bookplace) in
            timestr += "\(bookplace.startTrainTime) "
        }

        self.time = time
        
//        let tapGesture = UITapGestureRecognizer (target: self, action: #selector(imgTap(tapGesture:)))
//        trainerImg.addGestureRecognizer(tapGesture)
        
        self.timeCollect.delegate = self
        self.timeCollect.dataSource = self
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return time.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimeButtonCollection", for: indexPath) as! TimeButtonCollectionViewCell

        cell.timeBtn.layer.cornerRadius = 17
        cell.timeBtn.layer.borderWidth = 1
        cell.timeBtn.layer.borderColor = UIColor.gray.cgColor
        
        cell.timeBtn.accessibilityHint = "tag: \(self.trainerNo) row: \(indexPath.row) section: \(indexPath.section)"
        if self.buttonIdPendingAlready.contains(self.time[indexPath.row].key) {
            cell.timeBtn.setTitleColor(UIColor.red, for: .normal)
            cell.timeBtn.isEnabled = false
        }
        cell.delegate = self
        cell.setDataToButton(bookPlaceDetail: time[indexPath.row])

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(time[indexPath.row].key)
        
    }
}
