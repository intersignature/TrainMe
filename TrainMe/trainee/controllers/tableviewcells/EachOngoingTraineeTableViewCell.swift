//
//  EachOngoingTraineeTableViewCell.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 8/12/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit

class EachOngoingTraineeTableViewCell: UITableViewCell {

    @IBOutlet weak var countLb: UILabel!
    @IBOutlet weak var dateAndTimeLb: UILabel!
    @IBOutlet weak var statusLb: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func changeScheduleBtnAction(_ sender: UIButton) {
    }
    
    @IBAction func reviewBtnAction(_ sender: UIButton) {
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
