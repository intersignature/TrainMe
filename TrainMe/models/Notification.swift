//
//  Notification.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 6/1/2562 BE.
//  Copyright © 2562 Sirichai Binchai. All rights reserved.
//

import Foundation

class Notification {
    
    var toUid: String = "-1"
    var fromUid: String = "-1"
    var description: String = "-1"
    var isRead: String = "-1"
    var timeStamp: String = "-1"
    
    init() {}
    
    init(toUid: String, fromUid: String, description: String, isRead: String, timeStamp: String) {
        
        self.toUid = toUid
        self.fromUid = fromUid
        self.description = description
        self.isRead = isRead
        self.timeStamp = timeStamp
    }
    
    func getData() -> String {
        return "toUid: \(self.toUid)\nfromUid: \(self.fromUid)\ndescription: \(self.description)\nisRead: \(self.isRead)\ntimeStamp: \(self.timeStamp)\n"
    }
}
