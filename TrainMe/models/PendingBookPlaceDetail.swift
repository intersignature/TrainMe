//
//  PendingBookPlaceDetail.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 23/10/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import Foundation
import UIKit

class PendingBookPlaceDetail {
    
    var trainee_id: String = "-1"
    var trainer_id: String = "-1"
    var course_id: String = "-1"
    var place_id: String = "-1"
    var start_train_date: String = "-1"
    var start_train_time: String = "-1"
    var schedule_key: String = "-1"
    var is_trainer_accept = "-1"
    
    init() {}
    
    init(trainee_id: String, course_id: String, place_id: String, start_train_date: String, start_train_time: String, schedule_key: String, is_trainer_accept: String) {
        
        self.trainee_id = trainee_id
        self.course_id = course_id
        self.place_id = place_id
        self.start_train_date = start_train_date
        self.start_train_time = start_train_time
        self.schedule_key = schedule_key
        self.is_trainer_accept = is_trainer_accept
    }
    
    init(trainer_id: String, course_id: String, place_id: String, start_train_date: String, start_train_time: String, schedule_key: String, is_trainer_accept: String) {
        
        self.trainer_id = trainer_id
        self.course_id = course_id
        self.place_id = place_id
        self.start_train_date = start_train_date
        self.start_train_time = start_train_time
        self.schedule_key = schedule_key
        self.is_trainer_accept = is_trainer_accept
    }
    
    func getData() -> String {
        return "trainee_id: \(self.trainee_id)\ntrainer_id: \(self.trainer_id)\ncourse_id: \(self.course_id)\nplace_id: \(self.place_id)\nstart_train_date: \(self.start_train_date)\nstart_train_time: \(self.start_train_time)\nschedule: \(self.schedule_key)\nis_trainer_accept: \(self.is_trainer_accept)\n"
    }
}
