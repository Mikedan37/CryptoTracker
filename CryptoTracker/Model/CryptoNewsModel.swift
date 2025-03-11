//  CryptoNewsModel.swift
//  CryptoTracker
//  Created by Michael Danylchuk on 3/3/25.

import Foundation

struct CryptoNews: Identifiable {
    let id = UUID()
    let title: String
    let source: String
    let publishedAt: Date
    let ticker: String
    let url: String // Add this line
}

struct NewsAPIResponse: Codable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}

struct Article: Codable {
    let title: String
    let source: Source
    let publishedAt: String
    let url: String // ✅ Add this line
}

struct Source: Codable {
    let name: String
}
