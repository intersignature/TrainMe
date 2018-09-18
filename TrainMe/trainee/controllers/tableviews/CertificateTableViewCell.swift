//
//  CertificateTableViewCell.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 18/9/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit

class CertificateTableViewCell: UITableViewCell {

    @IBOutlet weak var certificateImg: UIImageView!
    @IBOutlet weak var certificateTv: UITextView!
    
    func setDataToCell(certificate: Certificate) {
        self.certificateImg.image = certificate.certImg
        self.certificateTv.text = certificate.certDetail
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
