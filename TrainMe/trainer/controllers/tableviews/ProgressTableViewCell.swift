//
//  ProgressTableViewCell.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 24/10/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit

class ProgressTableViewCell: UITableViewCell {

    @IBOutlet weak var traineeName: UILabel!
    @IBOutlet weak var Detail: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var status: UILabel!
    
    func setDataToCell(traineeName: String, detail: String, time: String, status: String) {
        
        self.traineeName.text = traineeName
        self.Detail.text = detail
        self.time.text = time
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
