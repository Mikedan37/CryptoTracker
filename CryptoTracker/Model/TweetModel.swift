//  TweetModel.swift
//  CryptoTracker
//
//  Created by Michael Danylchuk on 3/9/25.

import Foundation

struct Tweet: Codable, Identifiable {
    let id: String
    let text: String
    let created_at: String
}

struct TwitterAPIResponse: Codable {
    let data: [Tweet]?
}


