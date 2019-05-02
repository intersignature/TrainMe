//
//  Notification.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 6/1/2562 BE.
//  Copyright © 2562 Sirichai Binchai. All rights reserved.
//

import Foundation

class Notification {
    
    var id: String = "-1"
    var toUid: String = "-1"
    var fromUid: String = "-1"
    var description: String = "-1"
    var isRead: String = "-1"
    var timeStamp: String = "-1"
    var canReport: String = "-1"
    var isReport: String = "-1"
    
    init() {}
    
    init(id: String, toUid: String, fromUid: String, description: String, isRead: String, timeStamp: String, isReport: String) {
        
        self.id = id
        self.toUid = toUid
        self.fromUid = fromUid
        self.description = description
        self.isRead = isRead
        self.timeStamp = timeStamp
        self.checkReport(description: self.description)
        self.isReport = isReport
    }
    
    func checkReport(description: String) {
        if description.contains("Trainer was declined your booking because") {
            canReport = "1"
        } else {
            canReport = "0"
        }
    }
    
    func getData() -> String {
        return "id: \(self.id)\ntoUid: \(self.toUid)\nfromUid: \(self.fromUid)\ndescription: \(self.description)\nisRead: \(self.isRead)\ntimeStamp: \(self.timeStamp)\ncanReport: \(self.canReport)"
    }
}
// 0 1
