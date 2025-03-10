//
//  SearchView.swift
//  CryptoTracker
//
//  Created by Michael Danylchuk on 3/8/25.
//
import SwiftUI

struct SearchView: View {
    @Binding var cryptoCoins: [CryptoCoin] // All available coins passed in
    @Binding var watchlist: [CryptoCoin] // Your main watchlist
    @Binding var showSearchSheet: Bool // Controls sheet visibility

    @State private var searchText: String = ""
    @AppStorage("watchlist") private var storedWatchlist: Data = Data()

    var filteredCoins: [CryptoCoin] {
        if searchText.isEmpty {
            print(cryptoCoins)
            return cryptoCoins  // ✅ Ensures ALL coins show when search text is empty
        } else {
            return cryptoCoins.filter {
                $0.name.lowercased().contains(searchText.lowercased()) ||
                $0.ticker.lowercased().contains(searchText.lowercased())
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                searchBar  // (defined below)

                List {
                    ForEach(filteredCoins, id: \.id) { coin in
                        coinRow(for: coin) // (defined below)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Add to Watchlist")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showSearchSheet = false
                    }
                }
            }
        }
        .onAppear {
            loadWatchlist()
        }
        .onChange(of: cryptoCoins) { _ in
            loadWatchlist()
        }
    }

    // MARK: - Subviews

    private var searchBar: some View {
        TextField("Search for a coin...", text: $searchText)
            .padding()
            .textFieldStyle(RoundedBorderTextFieldStyle())
    }

    private func coinRow(for coin: CryptoCoin) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(coin.name)
                    .font(.headline)
                Text("\(coin.ticker.uppercased()) - \(coin.price, specifier: "%.2f") USD")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: watchlist.contains(where: { $0.ticker == coin.ticker }) ? "checkmark.circle.fill" : "plus.circle.fill")
                .foregroundColor(watchlist.contains(where: { $0.ticker == coin.ticker }) ? .green : .blue)
        }
        .padding(5)
        .onTapGesture {
            toggleWatchlistStatus(for: coin)
        }
    }

    // MARK: - Helper Methods

    private func toggleWatchlistStatus(for coin: CryptoCoin) {
        if let index = watchlist.firstIndex(where: { $0.ticker == coin.ticker }) {
            watchlist.remove(at: index)
        } else {
            var newCoin = coin
            newCoin.priceHistory.append(PriceEntry(price: coin.price, date: Date()))
            watchlist.append(newCoin)
        }
        saveWatchlist()
    }

    func saveWatchlist() {
        do {
            let encoded = try JSONEncoder().encode(watchlist)
            storedWatchlist = encoded
            print("✅ Watchlist saved successfully. Data: \(watchlist)")
        } catch {
            print("❌ Failed to save watchlist: \(error)")
        }
    }

    func loadWatchlist() {
        if let decoded = try? JSONDecoder().decode([CryptoCoin].self, from: storedWatchlist) {
            watchlist = decoded.map { savedCoin in
                var updatedCoin = savedCoin
                if updatedCoin.priceHistory.isEmpty {
                    print("⚠️ No price history found for \(updatedCoin.ticker), adding placeholder entry.")
                    updatedCoin.priceHistory.append(PriceEntry(price: updatedCoin.price, date: Date()))
                } else {
                    print("✅ Loaded full price history for \(updatedCoin.ticker): \(updatedCoin.priceHistory)")
                }
                return updatedCoin
            }
        } else {
            print("❌ Failed to load watchlist or no data available.")
        }
    }
}
