//
//  TimeButtonCollectionViewCell.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 2/10/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit

protocol TimeButtonCollectionCellDelegate {

    func didTapTimeButoon(bookPlaceDetailTapObject: BookPlaceDetail)
}

class TimeButtonCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var timeBtn: UIButton!
    var bookPlaceDetail: BookPlaceDetail!
    var delegate: TimeButtonCollectionCellDelegate?
    
    func setDataToButton(bookPlaceDetail: BookPlaceDetail) {
        
        self.timeBtn.setTitle(bookPlaceDetail.startTrainTime, for: .normal)
        self.bookPlaceDetail = bookPlaceDetail
    }
    
    @IBAction func timeBtnAction(_ sender: UIButton) {
        print(bookPlaceDetail.getData())
        delegate?.didTapTimeButoon(bookPlaceDetailTapObject: bookPlaceDetail)
        print(sender.accessibilityHint as? String)
    }
}
