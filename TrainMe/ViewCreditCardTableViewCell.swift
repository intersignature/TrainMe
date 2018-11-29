//
//  ViewCreditCardTableViewCell.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 28/11/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit

class ViewCreditCardTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var bankLb: UILabel!
    @IBOutlet weak var bgContainerView: UIView!
    @IBOutlet weak var last4digits: UILabel!
    @IBOutlet weak var brandLb: UILabel!
    
    func setDataToCell(name: String, bank: String, last4digits: String, brand: String) {
        
        self.nameLb.text = name
        self.bankLb.text = bank
        self.last4digits.text = "****    ****    ****    \(last4digits)"
        self.brandLb.text = brand
        self.bgContainerView.layer.cornerRadius = 5
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
