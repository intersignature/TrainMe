//
//  Help.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 30/12/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import Foundation
import UIKit

class Help {
    
    var topic: String = "-1"
    var desc: String = "-1"
    var imageSource: UIImage? = nil
    
    init(topic: String, desc: String, imageSource: UIImage?) {
        
        self.topic = topic
        self.desc = desc
        self.imageSource = imageSource
    }
    
    func getData() -> String {
        return "topic: \(self.topic)\ndesc: \(self.desc)\nimageSource: \(self.imageSource)"
    }
}
