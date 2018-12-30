//
//  Help.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 30/12/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import Foundation

class Help {
    
    var topic: String = "-1"
    var desc: String = "-1"
    
    init(topic: String, desc: String) {
        
        self.topic = topic
        self.desc = desc
    }
    
    func getData() -> String {
        return "topic: \(self.topic)\ndesc: \(self.desc)"
    }
}
