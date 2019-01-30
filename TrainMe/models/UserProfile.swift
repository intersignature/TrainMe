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
    var email: String = "-1"
    var dateOfBirth: String = "-1"
    var weight: String = "-1"
    var height: String = "-1"
    var gender: String = "-1"
    var role: String = "trainer"
    var profileImageUrl: String = "-1"
    var uid: String = "-1"
    var omiseCusId: String = "-1"
    var ban: Bool = false
    
    init(){}
    
    init(fullName: String?, email: String?,dateOfBirth: String?, weight: String?, height: String?, gender: String?, role: String?, profileImageUrl: String?, omiseCusId: String?, ban: Bool?) {
        
        self.fullName = fullName!
        self.email = email!
        self.dateOfBirth = dateOfBirth!
        self.weight = weight!
        self.height = height!
        self.gender = gender!
        self.role = role!
        self.profileImageUrl = profileImageUrl!
        self.omiseCusId = omiseCusId!
        self.ban = ban!
    }
    
    init(fullName: String?, email: String?,dateOfBirth: String?, weight: String?, height: String?, gender: String?, role: String?, profileImageUrl: String?, uid: String?, omiseCusId: String?, ban: Bool?) {
        
        self.fullName = fullName!
        self.email = email!
        self.dateOfBirth = dateOfBirth!
        self.weight = weight!
        self.height = height!
        self.gender = gender!
        self.role = role!
        self.profileImageUrl = profileImageUrl!
        self.uid = uid!
        self.omiseCusId = omiseCusId!
        self.ban = ban!
    }
    
    func getData() -> String {
        
        return "Fullname: \(self.fullName)\nemail: \(self.email)\nDateOfBirth: \(self.dateOfBirth)\nWeight: \(self.weight)Kg\nHeight: \(self.height)Cm\nGender: \(self.gender)\nRole: \(self.role)\nProfileImageUrl: \(self.profileImageUrl)\nUID: \(self.uid)\nOmise id: \(self.omiseCusId)\nBan: \(self.ban)\n------------------"
    }
}
