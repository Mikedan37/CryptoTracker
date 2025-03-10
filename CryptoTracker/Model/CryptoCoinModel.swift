//  CryptoCoinModel.swift
//  CryptoTracker
//  Created by Michael Danylchuk on 3/3/25.

import Foundation

struct CryptoCoin: Identifiable, Codable, Equatable {
    var id: String { ticker } // ✅ Use ticker as unique ID
    let name: String
    let ticker: String
    var price: Double
    var previousPrice: Double?
    var priceHistory: [PriceEntry] = []
    var about: String? // ✅ Add this field
    
    static func == (lhs: CryptoCoin, rhs: CryptoCoin) -> Bool {
        lhs.ticker == rhs.ticker &&
        lhs.price == rhs.price &&
        lhs.previousPrice == rhs.previousPrice
    }
}

struct PriceEntry: Identifiable, Codable {
    let id = UUID()
    let price: Double
    let date: Date
}
