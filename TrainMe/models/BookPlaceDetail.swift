//
//  BookPlaceDetail.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 10/9/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import Foundation

struct BookPlaceDetail {
    
    var key: String = "-1"
//    var placeId: String = "-1"
    var trainerId: String = "-1"
    var startTrainDate: String = "-1"
    var startTrainTime: String = "-1"
    
    init() {}
    
    init(key: String, trainerId: String, startTrainDate: String, startTrainTime: String) {
        self.key = key
        self.trainerId = trainerId
//        self.placeId = placeId
        self.startTrainDate = startTrainDate
        self.startTrainTime = startTrainTime
    }
    
    func getData() -> String {
        return "key: \(self.key)\ntrainer_id: \(self.trainerId)\nstartTrainDate: \(self.startTrainDate)\nstartTrainTime: \(self.startTrainTime)"
    }
}
