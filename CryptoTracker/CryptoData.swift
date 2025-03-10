//
//  CryptoData.swift
//  CryptoTracker
//
//  Created by Michael Danylchuk on 3/9/25.
//

import Foundation

class CryptoData: ObservableObject {
    @Published var watchlist: [CryptoCoin] = []
}
