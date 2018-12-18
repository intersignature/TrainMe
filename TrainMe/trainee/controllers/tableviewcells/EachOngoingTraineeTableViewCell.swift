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
    @IBOutlet weak var changeScheduleBtn: UIButton!
    @IBOutlet weak var reviewBtn: UIButton!
    
    var selectedOngoing: EachOngoingDetail!
    
    func setDataToCell() {
        
        self.countLb.text = selectedOngoing.count
        self.dateAndTimeLb.text = "\(selectedOngoing.start_train_date) \(selectedOngoing.start_train_time)"
        self.statusLb.text = selectedOngoing.status
    }
    
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
