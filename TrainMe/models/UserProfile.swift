//
//  UserProfile.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 28/8/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import Foundation

struct UserProfile {
    
    var fullName: String = "-1"
    var dateOfBirth: String = "-1"
    var weight: String = "-1"
    var height: String = "-1"
    var gender: String = "-1"
    var role: String = "trainer"
    var profileImageUrl: String = "-1"
    
    init(){}
    
    init(fullName: String?, dateOfBirth: String?, weight: String?, height: String?, gender: String?, role: String?, profileImageUrl: String?) {
        
        self.fullName = fullName!
        self.dateOfBirth = dateOfBirth!
        self.weight = weight!
        self.height = height!
        self.gender = gender!
        self.role = role!
        self.profileImageUrl = profileImageUrl!
    }
    
    func getData() -> String {
        
        return "Fullname: \(self.fullName)\nDateOfBirth: \(self.dateOfBirth)\nWeight: \(self.weight)Kg\nHeight: \(self.height)Cm\nGender: \(self.gender)\nRole: \(self.role)\nProfileImageUrl: \(self.profileImageUrl)\n------------------"
    }
}
