//
//  EachOngoingTrainerTableViewCell.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 19/12/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit

class EachOngoingTrainerTableViewCell: UITableViewCell {

    
    @IBOutlet weak var countLb: UILabel!
    @IBOutlet weak var dateAndTimeScheduleLb: UILabel!
    @IBOutlet weak var statusLb: UILabel!
    @IBOutlet weak var changeScheduleBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)


    }

}
