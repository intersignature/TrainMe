//
//  CreditCard.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 28/11/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import Foundation

struct CreditCard: Decodable {
    
    let object, id: String
    let livemode: Bool
    let location, defaultCard, email, description: String
    let metadata: Metadata
    let created: String
    let cards: Cards
    enum CodingKeys: String, CodingKey {
        case object, id, livemode, location
        case defaultCard = "default_card"
        case email, description, metadata, created, cards
    }
}

struct Cards: Decodable {

    let object: String
    let from, to: String
    let offset, limit, total: Int
    let order: String?
    let location: String
    let data: [Data]
}

struct Data: Decodable {
    let object, id: String
    let livemode: Bool
    let location, country: String
    let city, postalCode: String?
    let financing, bank, lastDigits, brand: String
    let expirationMonth, expirationYear: Int
    let fingerprint, name: String
    let securityCodeCheck: Bool
    let created: String
    enum CodingKeys: String, CodingKey {
        case object, id, livemode, location, country, city
        case postalCode = "postal_code"
        case financing, bank
        case lastDigits = "last_digits"
        case brand
        case expirationMonth = "expiration_month"
        case expirationYear = "expiration_year"
        case fingerprint, name
        case securityCodeCheck = "security_code_check"
        case created
    }
}

struct Metadata: Decodable {
}
