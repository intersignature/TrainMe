//
//  TimeButtonCollectionViewCell.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 2/10/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit

class TimeButtonCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var timeBtn: UIButton!
    var bookPlaceDetail: BookPlaceDetail!
    
    func setDataToButton(bookPlaceDetail: BookPlaceDetail) {
        
        self.timeBtn.setTitle(bookPlaceDetail.startTrainTime, for: .normal)
        self.bookPlaceDetail = bookPlaceDetail
    }
    
    @IBAction func timeBtnAction(_ sender: UIButton) {
        print(bookPlaceDetail.getData())
    }
}
