//  CoinManager.swift
//  CryptoTracker
//
//  Created by Michael Danylchuk on 3/10/25.

import Foundation

class coinSingleton: ObservableObject {
    // This will be the coin watchlist
    @Published var coins: [CryptoCoin] = []
    // This will store news on the coins
    @Published var news: [CryptoNews] = []
    // This will store current tweets about the coin
    @Published var tweets: [Tweet] = []
    
    // adds new coin data
    func fetchCoinData() async throws {
        
    }
    
    // Pulls news over the month
    // Only adds new news
    func fetchNews(for ticker: String) async throws{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date()) else {
            print("Error calculating one month ago date")
            return
        }
        
        var fromDate = dateFormatter.string(from: oneMonthAgo)
        
        // Adjust date if it equals the minimum allowed date.
        if fromDate == "2025-02-09" {
            if let adjustedDate = Calendar.current.date(byAdding: .day, value: 1, to: oneMonthAgo) {
                fromDate = dateFormatter.string(from: adjustedDate)
            } else {
                print("Error adjusting date by one day")
                return
            }
        }
        
        guard let url = URL(string: "https://newsapi.org/v2/everything?q=\(ticker)&from=\(fromDate)&sortBy=publishedAt&apiKey=1da275a4116e4ad0b44769083aa796fe") else {
            print("Invalid URL")
            return
        }
        
        print("Fetching news from: \(url)")
        
        do {
            // Await the data and response
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }
            
            // Decode the JSON response.
            let decodedResponse = try JSONDecoder().decode(NewsAPIResponse.self, from: data)
            
            // Update UI on the main thread.
            await MainActor.run {
                self.news = decodedResponse.articles.compactMap { article in
                    guard let articleURL = URL(string: article.url) else { return nil }
                    return CryptoNews(
                        title: article.title,
                        source: article.source.name,
                        publishedAt: ISO8601DateFormatter().date(from: article.publishedAt) ?? Date(),
                        ticker: ticker,
                        url: articleURL.absoluteString
                    )
                }
                .sorted { $0.publishedAt > $1.publishedAt }
                
                print("✅ News successfully fetched and stored.")
            }
        } catch {
            print("Error fetching or decoding data: \(error)")
            
            // Optionally, if you want to see the raw JSON string:
            if let jsonString = String(data: error as? Data ?? Data(), encoding: .utf8) {
                print("🔹 Received JSON: \(jsonString)")
            }
        }
    }
    
    // fetch tweet data
    func fetchTweetData() async throws {
        
    }
}

extension coinSingleton {
    
}

