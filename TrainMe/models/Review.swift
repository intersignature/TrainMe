//
//  Review.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 27/12/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import Foundation

class Review {
    
    var traineeUid: String = "-1"
    var trainerUid: String = "-1"
    var courseId: String = "-1"
    var eachReiew: [EachReview] = []
    
    
    init() {}
    
    init(traineeUid: String, trainerUid: String, courseId: String, eachReview: [EachReview]) {
        
        self.traineeUid = traineeUid
        self.trainerUid = trainerUid
        self.courseId = courseId
        self.eachReiew = eachReview
    }
    
    func getData() {
        
        print("traineeUid: \(self.traineeUid)\ntrainerUid: \(self.trainerUid)\ncourseId: \(self.courseId)\nEachReview: \(self.eachReiew)")
    }
}
