//
//  EachReview.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 27/12/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import Foundation

class EachReview {
    
    var rating: String = "-1"
    var reviewDesc: String = "-1"
    
    init() {}
    
    init(rating: String, reviewDesc: String) {
        self.rating = rating
        self.reviewDesc = reviewDesc
    }
    
    func getData() {
        print("rating: \(self.rating)\nreviewDesc: \(self.reviewDesc)")
    }
}
