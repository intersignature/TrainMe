//
//  Certificate.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 18/9/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import Foundation
import UIKit

class Certificate {
    
    var certImg: UIImage = UIImage()
    var certDetail: String = "-1"
    
    init() {}
    
    init(certImg: UIImage, certDetail: String) {
        self.certImg = certImg
        self.certDetail = certDetail
    }
    
    func getData() -> String {
        return "certImg: \(self.certImg)\ncertDetail: \(self.certDetail)"
    }
}
