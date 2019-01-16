//
//  Recipient.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 16/1/2562 BE.
//  Copyright © 2562 Sirichai Binchai. All rights reserved.
//

import Foundation

struct Recipient: Decodable {
    let object, id: String?
    let livemode: Bool?
    let location: String?
    let verified, active: Bool?
    let name, email, description, type: String?
    let taxID: String?
    let bankAccount: BankAccount
    let failureCode: String?
    let created: String?
    
    enum CodingKeys: String, CodingKey {
        case object, id, livemode, location, verified, active, name, email, description, type
        case taxID = "tax_id"
        case bankAccount = "bank_account"
        case failureCode = "failure_code"
        case created
    }
}

struct BankAccount: Decodable {
    let object, brand, lastDigits, name: String
    let created: String
    
    enum CodingKeys: String, CodingKey {
        case object, brand
        case lastDigits = "last_digits"
        case name, created
    }
}
