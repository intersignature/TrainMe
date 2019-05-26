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
    var courseVideoUrl: String = "-1"
    var courseType: String = "-1"
    var timeOfCourse: String = "-1"
    var courseDuration: String = "-1"
    var courseLevel: String = "-1"
    var coursePrice: String = "-1"
    var courseLanguage: String = "-1"
    var isDelete: String = "0"
    
    init() {}
    
    init(key: String, course: String, courseContent: String, courseVideoUrl:String, courseType: String, timeOfCourse: String,
         courseDuration: String, courseLevel: String, coursePrice: String, courseLanguage: String, isDelete: String) {
        
        self.key = key
        self.course = course
        self.courseContent = courseContent
        self.courseVideoUrl = courseVideoUrl
        self.courseType = decryptedCourseType(courseTypeCode: courseType)
        self.timeOfCourse = timeOfCourse
        self.courseDuration = courseDuration
        self.courseLevel = decryptedCourseLevel(courseLevelCode: courseLevel)
        self.coursePrice = coursePrice
        self.courseLanguage = courseLanguage
        self.isDelete = isDelete
    }
    
    func decryptedCourseType(courseTypeCode: String) -> String {
        
        let courseType = ["1": "healthy".localized(), "2": "fit_and_firm".localized(), "3": "competition".localized()]
        return courseType[courseTypeCode]!
    }
    
    func decryptedCourseLevel(courseLevelCode: String) -> String {
        
        let courseLevel = ["1": "all_level".localized(), "2": "intermediate".localized(), "3": "beginner".localized(), "4": "expert".localized()]
        return courseLevel[courseLevelCode]!
    }
    
    func getData() -> String{
        
        return "key: \(self.key)\ncourse: \(self.course)\ncourseContent: \(self.courseContent)\ncourseVideoUrl: \(self.courseVideoUrl)\ncourseType: \(self.courseType)\ntimeOfCourse: \(self.timeOfCourse)\ncourseDuration: \(self.courseDuration)\ncourseLevel: \(self.courseLevel)\ncoursePrice: \(self.coursePrice)\ncourseLanguage: \(self.courseLanguage)\nIsDelete: \(self.isDelete)------------------"
    }
}
