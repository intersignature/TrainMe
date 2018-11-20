//
//  EachOngoingDetail.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 20/11/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import Foundation

struct EachOngoingDetail {
    
    var start_train_date: String = "-1"
    var start_train_time: String = "-1"
    var status: String = "-1"
    var count: String = "-1"
    
    init() {}
    
    init(start_train_date: String, start_train_time: String, status: String, count: String) {
        
        self.start_train_date = start_train_date
        self.start_train_time = start_train_time
        self.status = status
        self.count = count
    }
}
