//
//  Course.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 4/9/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import Foundation

struct Course {
    
    var key: String = "-1"
    var course: String = "-1"
    var courseContent: String = "-1"
    var courseType: String = "-1"
    var timeOfCourse: String = "-1"
    var courseDuration: String = "-1"
    var courseLevel: String = "-1"
    var coursePrice: String = "-1"
    var courseLanguage: String = "-1"
    
    init() {}
    
    init(key: String, course: String, courseContent: String, courseType: String, timeOfCourse: String,
         courseDuration: String, courseLevel: String, coursePrice: String, courseLanguage: String) {
        
        self.key = key
        self.course = course
        self.courseContent = courseContent
        self.courseType = courseType
        self.timeOfCourse = timeOfCourse
        self.courseDuration = courseDuration
        self.courseLevel = courseLevel
        self.coursePrice = coursePrice
        self.courseLanguage = courseLanguage
    }

    func getData() -> String{
        
        return "key: \(self.key)\ncourse: \(self.course)\ncourseContent: \(self.courseContent)\ncourseType: \(self.courseType)\ntimeOfCourse: \(self.timeOfCourse)\ncourseDuration: \(self.courseDuration)\ncourseLevel: \(self.courseLevel)\ncoursePrice: \(self.coursePrice)\ncourseLanguage: \(self.courseLanguage)\n------------------"
    }
}
