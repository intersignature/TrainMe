//
//  OngoingDetail.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 20/11/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import Foundation

struct OngoingDetail {
    
    var ongoingId: String = "-1"
    var traineeId: String = "-1"
    var trainerId: String = "-1"
    var courseId: String = "-1"
    var placeId: String = "-1"
    var transactionToAdmin: String = "-1"
    var transactionToTrainer: String = "-1"
    var eachOngoingDetails: [EachOngoingDetail] = []
    
    init() {}
    
    init(ongoingId: String, traineeId: String, courseId: String, placeId: String, transactionToAdmin: String, transactionToTrainer: String, eachOngoingDetails: [EachOngoingDetail]) {
        
        self.ongoingId = ongoingId
        self.traineeId = traineeId
        self.courseId = courseId
        self.placeId = placeId
        self.transactionToAdmin = transactionToAdmin
        self.transactionToTrainer = transactionToTrainer
        self.eachOngoingDetails = eachOngoingDetails
    }
    
    init(ongoingId: String, trainerId: String, courseId: String, placeId: String, transactionToAdmin: String, transactionToTrainer: String, eachOngoingDetails: [EachOngoingDetail]) {
        
        self.ongoingId = ongoingId
        self.trainerId = trainerId
        self.courseId = courseId
        self.placeId = placeId
        self.transactionToAdmin = transactionToAdmin
        self.transactionToTrainer = transactionToTrainer
        self.eachOngoingDetails = eachOngoingDetails
    }
}
