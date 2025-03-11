//
//  ContentView.swift
//  CryptoTracker
//
//  Created by Michael Danylchuk on 3/2/25.
//

import SwiftUI
import WebKit
import Charts
import MessageUI

struct ContentView: View {
    @State private var selectedCoin: CryptoCoin? = CryptoCoin(name: "Bitcoin", ticker: "BTC", price: 32000.50)
    @AppStorage("watchlist") private var storedWatchlist: Data = Data()
    @State private var watchlist: [CryptoCoin] = []
    @State private var searchText: String = "" // Search text input
    @State private var showEmailPopover = false
    @State private var emailSubject: String = ""
    @State private var emailBody: String = ""
    @State private var showSearchSheet: Bool = false // Toggle for search view
    @State private var cryptoNews: [CryptoNews] = []
    @State private var selectedURL: URL? // Store selected article URL
    @State private var isWebViewPresented = false // Control WebView sheet
    @State private var selectedOption: String? = "News"
    @State private var isExpanded = false
    @State private var tweets: [Tweet] = []
    @State private var showWalletView2 = false
    @State private var showSettingsView2 = false
    // 1) Add these states near the top of your ContentView:
        @State private var showMailForm = false   // Toggles the sheet with your MailView
        @State private var toEmail: String = "support@cryptotracker.com"
        @State private var mailSubject: String = "Bug Report / Feedback"
        @State private var mailBody: String = """
    Hello,

    I found an issue with CryptoTracker...

    Steps to reproduce:
    1) ...
    2) ...

    Thanks for checking this out!
    """

    let options = ["News", "X.com", "About", "Chart", "History", "+"]
    
    let coinAboutInfo: [String: String] = [
        "BTC": "Bitcoin (BTC) is the world's first and most widely used decentralized digital currency, created in 2009 by an unknown person or group under the pseudonym Satoshi Nakamoto. It enables peer-to-peer transactions without intermediaries and is secured by blockchain technology. Bitcoin operates on a proof-of-work consensus mechanism, where miners validate transactions and secure the network. It has a fixed supply of 21 million coins, making it a deflationary asset often compared to digital gold. Bitcoin is widely accepted as a store of value and a hedge against inflation, with many institutions and countries integrating it into their financial systems.",
        
        "ETH": "Ethereum (ETH) is an open-source blockchain platform that allows developers to build and deploy smart contracts and decentralized applications (DApps). Launched in 2015 by Vitalik Buterin, it introduced the concept of decentralized finance (DeFi) and is transitioning to a proof-of-stake (PoS) system. Ethereum’s smart contract capabilities have led to the rise of non-fungible tokens (NFTs), DAOs, and other blockchain innovations. The Ethereum 2.0 upgrade aims to improve scalability, security, and energy efficiency. With its large developer community and extensive ecosystem, Ethereum remains the backbone of the DeFi and Web3 movement.",
        
        "BNB": "Binance Coin (BNB) is the native cryptocurrency of Binance, one of the world's largest cryptocurrency exchanges. Initially launched on Ethereum, BNB now powers the Binance Smart Chain (BSC), which supports DeFi applications and low-cost transactions. BNB is used for trading fee discounts, staking, and transaction fees on the Binance ecosystem. Binance regularly burns BNB tokens to reduce supply, increasing scarcity and potentially boosting its value over time. The Binance ecosystem includes Binance Pay, Binance NFT Marketplace, and various DeFi platforms, making BNB a utility token with extensive applications beyond trading.",
        
        "XRP": "XRP is a digital asset used in RippleNet, a global payments network developed by Ripple Labs. XRP aims to facilitate fast and cost-effective international money transfers, offering settlement times of just a few seconds compared to traditional banking systems. Unlike Bitcoin and Ethereum, XRP does not rely on mining; instead, it uses a unique consensus algorithm to validate transactions. Its primary use case is to enable cross-border transactions with minimal fees and liquidity constraints. Many financial institutions are exploring RippleNet for remittances and corporate payment solutions due to its efficiency and speed.",
        
        "ADA": "Cardano (ADA) is a blockchain platform developed by Input Output Hong Kong (IOHK) and co-founded by Charles Hoskinson. It focuses on scalability, interoperability, and sustainability, utilizing a unique proof-of-stake consensus mechanism called Ouroboros. Cardano is known for its rigorous academic approach, with peer-reviewed research guiding its development. The platform enables secure smart contracts and aims to provide decentralized financial services, particularly in developing nations. Cardano’s multi-layered architecture allows for future upgrades without disrupting the network, positioning it as a highly adaptable blockchain ecosystem.",
        
        "DOGE": "Dogecoin (DOGE) was originally created as a joke in 2013 but gained popularity due to its active community and support from public figures like Elon Musk. It operates as a decentralized, low-cost, and fast digital currency, often used for tipping and donations. Unlike Bitcoin, Dogecoin has no maximum supply, meaning new coins are continuously mined, which can lead to inflation. Despite this, Dogecoin has been widely adopted for microtransactions and charitable fundraising. Major companies, including Tesla, have started accepting Dogecoin as payment, further increasing its mainstream adoption.",
        
        "DOT": "Polkadot (DOT) is a multi-chain network that enables different blockchains to interoperate and share information securely. Developed by Gavin Wood, a co-founder of Ethereum, Polkadot enhances scalability and flexibility through its parachain structure. This architecture allows multiple blockchains to run in parallel, reducing congestion and increasing efficiency. DOT tokens are used for governance, staking, and bonding parachains, making them an essential part of the network’s ecosystem. With its focus on interoperability, Polkadot aims to create a decentralized web where data and assets can move freely across different blockchains.",
        
        "SOL": "Solana (SOL) is a high-performance blockchain known for its speed and efficiency, capable of processing thousands of transactions per second. It uses a unique proof-of-history (PoH) consensus mechanism to improve scalability while maintaining low transaction fees. Solana has become a preferred platform for DeFi projects, NFT marketplaces, and gaming applications due to its fast transaction speeds. However, it has faced occasional network outages due to its rapid growth and high usage demands. Solana’s ecosystem is expanding with innovative projects in Web3, metaverse applications, and real-time decentralized finance solutions.",
        
        "LTC": "Litecoin (LTC) is a peer-to-peer cryptocurrency created by Charlie Lee in 2011. It is often referred to as the 'silver to Bitcoin's gold' and offers faster transaction confirmation times and a different hashing algorithm (Scrypt). Litecoin was one of the first altcoins and has been widely adopted for payments and remittances. Its network processes transactions four times faster than Bitcoin, making it a more practical choice for day-to-day digital payments. Litecoin has also implemented key upgrades like MimbleWimble for privacy enhancements, improving its role as a fast, secure, and efficient payment method.",
        
        "LINK": "Chainlink (LINK) is a decentralized oracle network that connects smart contracts with real-world data. By enabling secure and reliable data feeds, Chainlink enhances the functionality of decentralized applications (DApps) across multiple blockchain ecosystems. The network provides tamper-proof data sources for DeFi platforms, insurance protocols, and supply chain management. Chainlink’s oracles ensure that smart contracts execute accurately based on real-world events, improving blockchain automation. Many enterprises are integrating Chainlink’s services, making it a crucial component for bringing off-chain data onto blockchain networks.",
        
        // Stablecoins
            "USDT": "Tether (USDT) is a stablecoin designed to maintain a 1:1 peg with the US dollar. It’s widely used for trading and hedging volatility, offering a predictable value in a market that’s otherwise a hot mess.",
            "USDC": "USD Coin (USDC) is a fully collateralized stablecoin pegged to the US dollar. Issued by regulated financial institutions, it provides transparency and stability, making it a safe harbor when crypto storms hit.",
            
            // Other cryptocurrencies
            "AVAX": "Avalanche (AVAX) is a high-performance blockchain platform known for its speed and scalability. Its innovative consensus mechanism makes it a serious contender in the smart contract arena.",
            "TRX": "TRON (TRX) is a blockchain platform aimed at decentralizing the internet. It boasts high throughput and low fees, making it a favorite for content and entertainment dApps.",
            "MATIC": "Polygon (MATIC) is a Layer 2 scaling solution for Ethereum that boosts transaction speed and cuts costs. It’s become essential for developers who can’t stand waiting around.",
            "WBTC": "Wrapped Bitcoin (WBTC) is Bitcoin tokenized on the Ethereum blockchain, bridging the gap between Bitcoin’s store-of-value appeal and Ethereum’s versatile DeFi ecosystem.",
            "SHIB": "Shiba Inu (SHIB) started as a meme coin and quickly evolved into a speculative asset. Its wild ride reflects the unpredictable and sometimes absurd nature of crypto hype.",
            "ICP": "Internet Computer (ICP) aims to reinvent the internet by running smart contracts at web speed. Its ambitious design seeks to decentralize traditional web services in a big way.",
            "BCH": "Bitcoin Cash (BCH) forked from Bitcoin to offer larger block sizes and faster transactions, making it a more practical choice for everyday payments despite the drama surrounding its split.",
            "NEAR": "NEAR Protocol (NEAR) is a developer-friendly blockchain that emphasizes scalability and usability. Its sharding technology and intuitive design are built for mainstream adoption.",
            "UNI": "Uniswap (UNI) powers one of the most popular decentralized exchanges on Ethereum. By enabling seamless token swaps without intermediaries, it’s a trailblazer in the DeFi revolution.",
            "ATOM": "Cosmos (ATOM) is all about blockchain interoperability. Its modular framework lets different chains communicate, creating an 'Internet of Blockchains' that’s as ambitious as it is essential.",
            "XLM": "Stellar (XLM) is a blockchain platform designed for fast and low-cost cross-border payments. It bridges traditional finance and crypto, making international money transfers a breeze.",
            "APT": "Aptos (APT) is a next-gen blockchain that promises high throughput and enhanced safety with its novel consensus mechanism. It’s built by industry veterans aiming to redefine dApp development.",
            "OKB": "OKB is the native token of the OKX exchange, offering benefits like trading fee discounts, staking rewards, and governance rights. It’s a utility token that keeps the exchange’s ecosystem humming.",
            "LEO": "LEO Token is the native asset of the Bitfinex exchange, designed to reward loyalty with perks such as reduced trading fees and exclusive features. It’s Bitfinex’s way of saying ‘thanks for sticking around.’",
            "ETC": "Ethereum Classic (ETC) is the original Ethereum chain that stayed true to its immutable roots after a controversial split. It holds a niche spot for those who value decentralization over change.",
            "FIL": "Filecoin (FIL) is a decentralized storage network that turns unused storage into a commodity. It connects users with storage providers, offering a censorship-resistant alternative to traditional cloud services.",
            "VET": "VeChain (VET) focuses on supply chain management, using blockchain to boost transparency and traceability. It’s all about ensuring authenticity from factory to consumer.",
            "HBAR": "Hedera Hashgraph (HBAR) isn’t technically a blockchain—it uses a hashgraph consensus to deliver high throughput and fast finality. It’s geared toward enterprise applications that demand both speed and security.",
            "XAUT": "Tether Gold (XAUT) ties digital assets to physical gold, merging the stability of a tangible asset with the efficiency of blockchain. It’s perfect for those who like their crypto with a side of old-school value.",
            "MNT": "Mantle (MNT) is a layer-2 blockchain solution aiming to offer scalable and cost-effective infrastructure for dApps. It’s designed to reduce fees and speed up transactions, because who has time to wait?",
            "CRO": "Crypto.com Coin (CRO) fuels the Crypto.com ecosystem, granting users benefits like fee discounts and staking rewards. It’s central to a platform that’s all about making crypto accessible.",
            "ARB": "Arbitrum (ARB) is a layer-2 scaling solution for Ethereum that uses rollups to slash fees and speed up transactions. It’s the answer for developers tired of Ethereum’s congestion.",
            "QNT": "Quant (QNT) bridges disparate blockchains with its Overledger technology, enabling seamless cross-chain communication. It’s built for enterprises that need to connect multiple networks without the hassle.",
            "ALGO": "Algorand (ALGO) offers a high-performance, secure blockchain with a pure proof-of-stake consensus. It’s designed to be fast, efficient, and ready for a wide range of applications.",
            "DAI": "Dai (DAI) is a decentralized stablecoin pegged to the US dollar, maintained through collateral and smart contracts. Its algorithmic stability provides a reliable medium of exchange in a volatile market.",
            "MKR": "Maker (MKR) governs the MakerDAO system, which issues the Dai stablecoin. MKR holders steer the platform’s risk management and stability, ensuring that everything runs without a hitch.",
            "OP": "Optimism (OP) is a layer-2 scaling solution for Ethereum that leverages optimistic rollups to increase throughput and slash gas fees. It’s a must-have for anyone fed up with high transaction costs.",
            "IMX": "Immutable X (IMX) is tailored for NFTs on Ethereum, offering fast transactions with zero gas fees. It empowers creators and gamers alike to trade digital assets without the usual blockchain headaches.",
            "RNDR": "Render Token (RNDR) connects artists with unused GPU power for decentralized rendering. It transforms digital art creation by tapping into a global network of computing resources.",
            "AAVE": "Aave (AAVE) is a DeFi protocol that lets users lend and borrow cryptocurrencies without intermediaries. It’s loaded with innovative features like flash loans, making it a DeFi heavyweight.",
            "INJ": "Injective Protocol (INJ) offers a fully decentralized derivatives trading platform on layer-2. By cutting out intermediaries, it creates a transparent and efficient market for financial instruments.",
            "SAND": "The Sandbox (SAND) powers a decentralized gaming ecosystem where users can create, own, and monetize digital assets. It’s at the intersection of gaming and blockchain, bringing virtual worlds to life.",
            "THETA": "Theta Token (THETA) is built to revolutionize video streaming by decentralizing content delivery. It rewards users for sharing bandwidth, ensuring smooth streaming without the corporate middleman.",
            "MANA": "Decentraland (MANA) fuels a virtual reality platform where users can buy, sell, and build on virtual land. It’s the cornerstone of a decentralized metaverse where creativity knows no bounds.",
            "STX": "Stacks (STX) brings smart contracts to Bitcoin, allowing for decentralized apps that leverage Bitcoin’s security. It’s perfect for innovators who want to build on the world’s original cryptocurrency.",
            "XTZ": "Tezos (XTZ) is a self-amending blockchain that supports smart contracts with on-chain governance. Its formal verification process ensures security and longevity, appealing to both developers and institutions.",
            "AXS": "Axie Infinity (AXS) is the heartbeat of the Axie Infinity gaming universe, driving in-game economies and community governance. It’s a central asset in the booming play-to-earn space.",
            "FTM": "Fantom (FTM) is a fast, scalable blockchain platform built for smart contracts and dApps. Its DAG-based consensus delivers near-instant finality, making it a strong player in high-speed transactions.",
            "NEO": "NEO is often dubbed the ‘Chinese Ethereum’ for its smart contract capabilities and focus on digital asset integration. It’s designed for the digital economy with a robust ecosystem.",
            "GALA": "Gala (GALA) is all about blockchain gaming, empowering players with true ownership of in-game assets. It’s a vibrant ecosystem that’s reshaping digital entertainment.",
            "FLOW": "Flow (FLOW) is built for next-gen digital experiences, especially in gaming and NFTs. Its scalable and developer-friendly design has attracted major brands and creators.",
            "KAVA": "Kava (KAVA) is a cross-chain DeFi platform offering lending, stablecoins, and more. It bridges traditional finance with crypto, providing secure and innovative financial products.",
            "RPL": "Rocket Pool (RPL) democratizes Ethereum 2.0 staking by letting users pool resources without running their own validator. It makes staking accessible and rewards more attainable.",
            "HNT": "Helium (HNT) powers a decentralized wireless network by incentivizing users to deploy hotspots. It’s a unique blend of blockchain and IoT that’s reshaping connectivity.",
            "COMP": "Compound (COMP) is a leading DeFi lending protocol where users can earn interest or borrow assets without a middleman. Governed by its community, it’s a benchmark for decentralized finance.",
            "CRV": "Curve DAO Token (CRV) is the governance token of Curve Finance, optimized for stablecoin swaps with low slippage. It’s integral to maintaining liquidity and efficiency in the DeFi ecosystem.",
            "KCS": "KuCoin Shares (KCS) is the native token of the KuCoin exchange, granting benefits like reduced fees and staking rewards. It’s essential for users looking to squeeze extra value from their trades.",
            "CHZ": "Chiliz (CHZ) fuels fan engagement in sports and entertainment by tokenizing the fan experience. It connects supporters with their favorite teams in a whole new, interactive way.",
            "MINA": "Mina Protocol (MINA) is known as the lightest blockchain, using recursive zero-knowledge proofs to keep its size constant. It’s designed for scalability without sacrificing decentralization.",
            "TWT": "Trust Wallet Token (TWT) is the native token of Trust Wallet, rewarding users with governance rights and staking perks. It enhances the security and functionality of one of crypto’s most popular wallets.",
            "ZIL": "Zilliqa (ZIL) employs sharding to achieve high throughput, making it ideal for applications requiring speed and security. Its innovative approach ensures that scaling is built into its DNA.",
            "CFX": "Conflux (CFX) is a public blockchain focused on scalability and interoperability. It uses novel consensus mechanisms to deliver fast transactions and support a wide range of applications.",
            "PAX": "Paxos Standard (PAX) is a regulated stablecoin pegged to the US dollar. It offers a secure, transparent bridge between traditional finance and the crypto world.",
            "DASH": "Dash is a digital currency engineered for instant, low-cost transactions. With features like InstantSend and PrivateSend, it combines speed and privacy for everyday use.",
            "NEXO": "Nexo is a crypto-backed lending platform that offers instant loans and high-yield interest on digital assets. Its native token facilitates a seamless borrowing and lending experience.",
            "LRC": "Loopring (LRC) is a protocol for decentralized exchanges that uses zkRollup technology to deliver high throughput with low fees. It’s all about efficient and secure trading.",
            "BTT": "BitTorrent (BTT) brings blockchain to the world of file sharing, incentivizing users to share resources on a decentralized network. It’s a modern twist on a classic peer-to-peer protocol.",
            "WAVES": "Waves is a versatile blockchain platform that lets users create and trade custom digital assets. Its intuitive tools and robust ecosystem support everything from token launches to dApp development.",
            "FXS": "Frax Share (FXS) is the governance token of the Frax protocol, a hybrid stablecoin system that blends algorithmic and collateralized elements. FXS holders steer the protocol to maintain stability.",
            "CAKE": "PancakeSwap Token (CAKE) powers PancakeSwap on the Binance Smart Chain, incentivizing liquidity and rewarding active participants. It’s a key asset in one of the most popular DeFi ecosystems on BSC.",
            "ZEC": "Zcash (ZEC) is a privacy-focused cryptocurrency that uses zero-knowledge proofs to enable shielded transactions. It offers strong privacy features while ensuring network security.",
            "MIOTA": "IOTA (MIOTA) is designed for the Internet of Things, using a unique Tangle architecture to facilitate feeless microtransactions. It’s built for a connected world where data and value move seamlessly.",
            "BAT": "Basic Attention Token (BAT) integrates into the digital advertising ecosystem, rewarding users for their attention and providing fair compensation for content creators. It’s all about creating a more transparent ad market.",
            "KSM": "Kusama (KSM) serves as a testing ground for innovative projects that eventually launch on Polkadot. Its experimental nature fosters rapid innovation in a less restrictive environment.",
            "ENJ": "Enjin Coin (ENJ) empowers game developers to tokenize in-game assets, enabling true ownership and interoperability across gaming platforms. It’s a cornerstone of blockchain gaming innovation.",
            "LUNA": "Terra Luna (LUNA) is a central player in the Terra ecosystem, which focuses on algorithmic stablecoins and decentralized finance. LUNA is key to maintaining the system’s stability and enabling its financial services.",
            "SUI": "Sui is a high-performance blockchain designed with scalability and user-friendliness in mind. Its innovative architecture supports a wide array of decentralized applications with ease.",
            "1INCH": "1inch (1INCH) is a decentralized exchange aggregator that scours multiple platforms to find the best rates for users. It optimizes trades to save you time and money.",
            "AGIX": "SingularityNET (AGIX) is a decentralized marketplace for AI services, allowing developers to share and monetize algorithms. It brings AI and blockchain together in a bold, innovative way.",
            "AR": "Arweave (AR) offers a unique, permanent data storage solution on a decentralized network. Its pay-once, store-forever model is perfect for archiving important information.",
            "OCEAN": "Ocean Protocol (OCEAN) enables secure and transparent data sharing by connecting data providers with consumers. It’s paving the way for a new data economy built on trust and accessibility.",
            "FET": "Fetch.ai (FET) combines blockchain with artificial intelligence to create autonomous economic agents. It’s all about making systems smarter and more efficient through decentralized AI solutions.",
            "RVN": "Ravencoin (RVN) is designed specifically for transferring digital assets, offering a streamlined and secure platform for token creation and transfer. It’s simple, efficient, and built for asset mobility.",
        
    ]

    @State private var cryptoCoins: [CryptoCoin] = []
    
    var body: some View {
        NavigationView {
            ZStack{
                Color.gray.brightness(-0.5).edgesIgnoringSafeArea(.all)
                VStack{
                    HStack(spacing:3){
                        VStack(alignment:.leading){
                            Text(formattedTodayDate()).font(.title).foregroundStyle(.white).multilineTextAlignment(.leading).bold()
                        }
                        //Text("March 6").font(.title).bold().foregroundStyle(.white)
                        Spacer()
                        Button(action: {
                            showMailForm = true
                        }, label: {
                            Image(systemName: "questionmark.bubble")
                                .imageScale(.large)
                                .foregroundStyle(.gray)
                                .bold()
                        })
                        .sheet(isPresented: $showMailForm) {
                                        MailView(
                                            toEmail: $toEmail,
                                            subject: $mailSubject,
                                            body: $mailBody,
                                            isShowing: $showMailForm
                                        )
                                    }
                        Button(action:{
                            showSearchSheet = true
                        },label:{
                            Image(systemName: "plus").foregroundStyle(.gray).font(.title3).imageScale(.large).bold()
                        }).sheet(isPresented: $showSearchSheet) {
                            SearchView(cryptoCoins: $cryptoCoins, watchlist: $watchlist, showSearchSheet: $showSearchSheet)
                        }
                        Button(action: {
                            withAnimation(.easeInOut) {
                                showWalletView2.toggle()
                            }
                        }, label: {
                            Image(systemName: "wallet.bifold")
                                .foregroundStyle(.gray)
                                .imageScale(.large)
                                .font(.headline)
                        })
                        .background(
                            NavigationLink(
                                destination: WalletVIew()
                                    .transition(.move(edge: .trailing)),
                                isActive: $showWalletView2
                            ) {
                                EmptyView()
                            }
                        )
                        
                        Button(action: {
                            withAnimation(.spring()) {
                                showSettingsView2.toggle()
                            }
                        }, label: {
                            Image(systemName: "gear")
                                .foregroundStyle(.gray)
                                .imageScale(.large)
                                .font(.headline)
                        })
                        .background(
                            NavigationLink(
                                destination: SettingsView()
                                    .transition(.move(edge: .bottom)),
                                isActive: $showSettingsView2
                            ) {
                                EmptyView()
                            }
                        )
                        //Text("$--.---").font(.title).bold().foregroundStyle(.white)
                        
                    }.padding(.horizontal,20).padding(.bottom,-15)
                    Rectangle().frame(width: UIScreen.main.bounds.width, height: 1).foregroundColor(.white).offset(x: 10,y: 10)
                    ScrollView {
                        ForEach(watchlist) { coin in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(coin.name).foregroundStyle(.white)
                                    Text("\(coin.ticker)").foregroundStyle(.white).font(.headline)
                                }
                                Spacer()
                                VStack {
                                    HStack{
                                        Spacer()
                                        Text("\(String(format: "%.2f", coin.price)) USD")
                                            .foregroundStyle(.white)
                                            .bold()
                                    }
                                    
                                    if let previousPrice = coin.previousPrice {
                                        let change = coin.price - previousPrice
                                        
                                        HStack{
                                            Spacer()
                                            Text(String(format: "%.2f$%", change))
                                                .foregroundColor(change >= 0 ? .green : .red) // Green for positive, Red for negative
                                                .bold()
                                        }
                                    }else{
                                        HStack{
                                            Spacer()
                                            Text(String(format: "%.2f$%", 0.00))
                                                .foregroundColor(.white) // Green for positive, Red for negative
                                                .bold()
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 5)
                            .background(selectedCoin?.ticker == coin.ticker ? Color.blue.opacity(0.3) : Color.clear)
                            .cornerRadius(10)
                            .onTapGesture {
                                if let index = watchlist.firstIndex(where: { $0.id == coin.id }) {
                                    watchlist[index].priceHistory.append(PriceEntry(price: watchlist[index].price, date: Date()))
                                    print("🔹 Manually added history entry for \(watchlist[index].ticker)")
                                    saveWatchlist()
                                }
                                
                                selectedCoin = watchlist.first(where: { $0.id == coin.id })
                                fetchNews(for: coin.ticker)
                            }
                        }
                    }.padding(.bottom, 356).padding(.top, 4)
                }.onAppear {
                    print("🚀 Loading watchlist and fetching only watchlist prices first...")
                    
                    self.loadWatchlist()
                    
                    // ✅ Only fetch prices for coins in the watchlist first
                    DispatchQueue.main.async {
                        self.fetchWatchlistPrices()
                    }
                    
                    // ✅ Wait 2s before fetching full market data
                    DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 2) {
                        self.fetchAllCryptoCoinsOnce()
                    }
                    
                    // ✅ Fetch news later (doesn't block UI)
                    DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 5) {
                        if let selectedTicker = self.selectedCoin?.ticker {
                            self.fetchNews(for: selectedTicker)
                        }
                    }
                    
                    // ✅ Delay timers so they don’t interfere with initial API calls
                    DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
                        Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { _ in
                            self.fetchWatchlistPrices()
                        }
                        
                        Timer.scheduledTimer(withTimeInterval: 120, repeats: true) { _ in
                            if let selectedTicker = self.selectedCoin?.ticker {
                                self.fetchNews(for: selectedTicker)
                            }
                        }
                    }
                }
                .onChange(of: watchlist) { newWatchlist in
                    print("🔄 Watchlist updated: \(newWatchlist)")
                }
                VStack{
                    Spacer()
                    ZStack{
                        Rectangle().fill(Color.white).frame(width: UIScreen.main.bounds.width, height: 380).offset(y:-10)
                        Rectangle().fill(Color.black).frame(width: UIScreen.main.bounds.width, height: 379).offset(y:-9)
                        VStack(spacing:3){
                            HStack(spacing:10){
                                ForEach(options, id: \.self) { option in
                                    Button(action: {
                                        selectedOption = option
                                    }) {
                                        Text(option)
                                            .bold()
                                            .padding(.vertical, 2)
                                            .padding(.horizontal, 7)
                                            .background(Color.gray)
                                            .foregroundColor(selectedOption == option ? Color.white : Color.black)
                                            .cornerRadius(5)
                                    }
                                }
                            }
                            Rectangle().frame(height:1).foregroundStyle(.white).padding(2)
                            ScrollView {
                                if selectedOption == "News" {
                                    ForEach(cryptoNews) { article in
                                        VStack(alignment: .leading, spacing: 5) {
                                            Button(action: {
                                                if let url = URL(string: article.url) {
                                                    selectedURL = url
                                                    isWebViewPresented = true
                                                }
                                            }) {
                                                Text("\(article.title)...")
                                                    .font(.headline)
                                                    .foregroundColor(.white) // Ensure it's visibly clickable
                                                    .underline()
                                                    .multilineTextAlignment(.leading)
                                            }
                                            .sheet(isPresented: $isWebViewPresented) {
                                                if let selectedURL = selectedURL {
                                                    WebView(url: selectedURL)
                                                }
                                            }
                                            Text("\(article.source) • \(formattedDate(article.publishedAt))")
                                                .foregroundColor(.white)
                                            
                                            Divider().background(Color.white)
                                        }
                                    }
                                } else if selectedOption == "History", let selectedCoin = selectedCoin {
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("\(selectedCoin.name) Price History")
                                            .foregroundColor(.white).bold()
                                            .font(.title2)
                                            .padding(.bottom, 5)
                                        
                                        if selectedCoin.priceHistory.isEmpty {
                                            Text("⚠️ No price history recorded yet.")
                                                .foregroundColor(.gray)
                                        } else {
                                            ForEach(selectedCoin.priceHistory.sorted(by: { $0.date > $1.date })) { entry in
                                                HStack {
                                                    Text("\(formattedDateFull(entry.date))")
                                                        .foregroundColor(.white.opacity(0.7))
                                                    Spacer()
                                                    Text("\(String(format: "%.2f USD", entry.price))")
                                                        .foregroundColor(.white)
                                                }
                                                Divider().background(Color.white)
                                            }
                                        }
                                    }
                                }
                                else if selectedOption == "About", let selectedCoin = selectedCoin {
                                    VStack(alignment: .leading, spacing: 5) {
                                        HStack{
                                            Text("About \(selectedCoin.name)")
                                                .foregroundColor(.white).bold()
                                                .font(.title2)
                                                .padding(.bottom, 5)
                                            Spacer()
                                        }
                                        Text(coinAboutInfo[selectedCoin.ticker] ?? "No information available.")
                                            .foregroundColor(.white)
                                            .padding(.bottom, 5)
                                    }
                                }
                                else if selectedOption == "Chart", let selectedCoin = selectedCoin {
                                    // Compute candlestick data outside the view builder
                                    let now = Date()
                                    let fifteenMinutesAgo = now.addingTimeInterval(-15 * 60)
                                    let recentHistory = selectedCoin.priceHistory.filter { $0.date >= fifteenMinutesAgo }
                                    let calendar = Calendar.current
                                    let grouped = Dictionary(grouping: recentHistory) { entry -> Date in
                                        var comps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: entry.date)
                                        comps.second = 0
                                        comps.nanosecond = 0
                                        return calendar.date(from: comps) ?? entry.date
                                    }
                                    let candlesticks: [Candlestick] = grouped.map { (time, entries) in
                                        let sortedEntries = entries.sorted { $0.date < $1.date }
                                        let open = sortedEntries.first!.price
                                        let close = sortedEntries.last!.price
                                        let high = sortedEntries.map { $0.price }.max()!
                                        let low = sortedEntries.map { $0.price }.min()!
                                        return Candlestick(time: time, open: open, close: close, high: high, low: low)
                                    }.sorted { $0.time < $1.time }
                                    
                                    let minPrice = candlesticks.map { $0.low }.min() ?? 0
                                    let maxPrice = candlesticks.map { $0.high }.max() ?? 1
                                    let range = maxPrice - minPrice
                                    let padding = range * 0.1
                                    
                                    Group {
                                        if candlesticks.isEmpty {
                                            Text("No candlestick data available")
                                                .foregroundColor(.white)
                                        } else {
                                            Chart {
                                                ForEach(candlesticks) { candle in
                                                    // Draw high-low line (wick)
                                                    BarMark(
                                                        x: .value("Time", candle.time),
                                                        yStart: .value("Low", candle.low),
                                                        yEnd: .value("High", candle.high),
                                                        width: .fixed(3)
                                                    )
                                                    .foregroundStyle(.gray)
                                                    
                                                    // Draw open-close rectangle (body)
                                                    BarMark(
                                                        x: .value("Time", candle.time),
                                                        yStart: .value("Open", min(candle.open, candle.close)),
                                                        yEnd: .value("Close", max(candle.open, candle.close)),
                                                        width: .fixed(12)
                                                    )
                                                    .foregroundStyle(candle.close >= candle.open ? .green : .red)
                                                }
                                            }
                                            .chartYScale(domain: (minPrice - padding)...(maxPrice - padding))
                                            .chartXAxis {
                                                AxisMarks(values: .automatic(desiredCount: 5))
                                            }
                                            .chartYAxis {
                                                AxisMarks()
                                            }
                                            .frame(height: 300)
                                            .padding()
                                        }
                                    }
                                }
                                else if selectedOption == "X.com" {
                                    // Compute grouped tweets in a local constant
                                    let tweetGroups: [(date: String, tweets: [Tweet])] = {
                                        let isoFormatter = ISO8601DateFormatter()
                                        let displayFormatter = DateFormatter()
                                        displayFormatter.dateStyle = .medium
                                        displayFormatter.timeStyle = .none
                                        
                                        // Group tweets by formatted date string
                                        let grouped = Dictionary(grouping: tweets) { tweet -> String in
                                            if let date = isoFormatter.date(from: tweet.created_at) {
                                                return displayFormatter.string(from: date)
                                            }
                                            return "Unknown Date"
                                        }
                                        
                                        // Sort the keys descending (most recent first)
                                        let sortedKeys = grouped.keys.sorted { key1, key2 in
                                            if let date1 = displayFormatter.date(from: key1),
                                               let date2 = displayFormatter.date(from: key2) {
                                                return date1 > date2
                                            }
                                            return key1 > key2
                                        }
                                        
                                        return sortedKeys.map { key in (date: key, tweets: grouped[key] ?? []) }
                                    }()
                                    
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("Recent Tweets")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        ForEach(tweetGroups, id: \.date) { group in
                                            VStack(alignment: .leading, spacing: 5) {
                                                // Date header
                                                Text(group.date)
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                                
                                                // Tweets for this date
                                                ForEach(group.tweets) { tweet in
                                                    Button(action: {
                                                        if let tweetURL = URL(string: "https://twitter.com/i/web/status/\(tweet.id)") {
                                                            selectedURL = tweetURL
                                                            isWebViewPresented = true
                                                        }
                                                    }) {
                                                        Text(tweet.text)
                                                            .foregroundColor(.white)
                                                            .padding(.vertical, 4)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.bottom, 15)
                                    .onAppear {
                                        // Fetch tweets for the selected coin ticker when "X.com" is selected
                                        if let ticker = selectedCoin?.ticker {
                                            fetchTweets(for: ticker)
                                        }
                                    }
                                }
                            }.padding(.horizontal, 10).padding(.bottom, 15).padding(.top,2)
                        }
                    }.frame(height: 300)
                }
            }.onChange(of: watchlist) { newWatchlist in
                print("🔄 Watchlist updated: \(newWatchlist)")
            }
        }
    }
    
    private func removeFromWatchlist(at offsets: IndexSet) {
        watchlist.remove(atOffsets: offsets)
    }
    
    func formattedDateFull(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter.string(from: date)
    }
    
    func fetchNews(for ticker: String) {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    guard let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date()) else {
        print("Error calculating one month ago date")
        return
    }
    // Convert to string
    var fromDate = dateFormatter.string(from: oneMonthAgo)
    
    // Check if the fromDate equals the minimum allowed date and adjust by one day if necessary
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
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }
            
            if let data = data {
                do {
                    let decodedResponse = try JSONDecoder().decode(NewsAPIResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.cryptoNews = decodedResponse.articles.compactMap { article in
                            guard let url = URL(string: article.url) else { return nil } // Ensure valid URL
                            return CryptoNews(
                                title: article.title,
                                source: article.source.name,
                                publishedAt: ISO8601DateFormatter().date(from: article.publishedAt) ?? Date(),
                                ticker: ticker,
                                url: url.absoluteString
                            )
                        }
                        .sorted { $0.publishedAt > $1.publishedAt } // ✅ Sort newest to oldest
                        
                        print("✅ News successfully fetched and stored.")
                    }
                } catch {
                    print("❌ Failed to decode JSON: \(error)")
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("🔹 Received JSON: \(jsonString)")
                    }
                }
            }
        }.resume()
    }
    
    // Mapping CoinGecko IDs to correct tickers
    let tickerMapping: [String: String] = [
        "bitcoin": "BTC",
        "ethereum": "ETH",
        "tether": "USDT",
        "binancecoin": "BNB",
        "solana": "SOL",
        "usd-coin": "USDC",
        "xrp": "XRP",
        "cardano": "ADA",
        "avalanche-2": "AVAX",
        "dogecoin": "DOGE",
        "polkadot": "DOT",
        "tron": "TRX",
        "chainlink": "LINK",
        "polygon": "MATIC",
        "wrapped-bitcoin": "WBTC",
        "shiba-inu": "SHIB",
        "internet-computer": "ICP",
        "litecoin": "LTC",
        "bitcoin-cash": "BCH",
        "near": "NEAR",
        "uniswap": "UNI",
        "cosmos": "ATOM",
        "stellar": "XLM",
        "aptos": "APT",
        "okb": "OKB",
        "leo-token": "LEO",
        "ethereum-classic": "ETC",
        "filecoin": "FIL",
        "vechain": "VET",
        "hedera-hashgraph": "HBAR",
        "tether-gold": "XAUT",
        "mantle": "MNT",
        "crypto-com-chain": "CRO",
        "arbitrum": "ARB",
        "quant": "QNT",
        "algorand": "ALGO",
        "dai": "DAI",
        "maker": "MKR",
        "optimism": "OP",
        "immutable-x": "IMX",
        "render-token": "RNDR",
        "aave": "AAVE",
        "injective-protocol": "INJ",
        "the-sandbox": "SAND",
        "theta-token": "THETA",
        "decentraland": "MANA",
        "stacks": "STX",
        "tezos": "XTZ",
        "axie-infinity": "AXS",
        "fantom": "FTM",
        "neo": "NEO",
        "gala": "GALA",
        "flow": "FLOW",
        "kava": "KAVA",
        "rocket-pool": "RPL",
        "helium": "HNT",
        "compound-governance-token": "COMP",
        "curve-dao-token": "CRV",
        "kucoin-shares": "KCS",
        "chiliz": "CHZ",
        "mina-protocol": "MINA",
        "trust-wallet-token": "TWT",
        "zilliqa": "ZIL",
        "conflux-token": "CFX",
        "paxos-standard": "PAX",
        "dash": "DASH",
        "nexo": "NEXO",
        "loopring": "LRC",
        "bittorrent": "BTT",
        "waves": "WAVES",
        "frax-share": "FXS",
        "pancakeswap-token": "CAKE",
        "zcash": "ZEC",
        "iota": "MIOTA",
        "basic-attention-token": "BAT",
        "kusama": "KSM",
        "enjincoin": "ENJ",
        "terra-luna-2": "LUNA",
        "sui": "SUI",
        "1inch": "1INCH",
        "singularitynet": "AGIX",
        "arweave": "AR",
        "ocean-protocol": "OCEAN",
        "fetch-ai": "FET",
        "ravencoin": "RVN"
    ]
    
    func fetchAllCryptoCoinsOnce() {
        let coinIDs = tickerMapping.keys.prefix(100).joined(separator: ",") // ✅ Fetch top 100 first
        let urlString = "https://api.coingecko.com/api/v3/simple/price?ids=\(coinIDs)&vs_currencies=usd"

        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }

            DispatchQueue.global(qos: .background).async {
                if let decodedResponse = try? JSONDecoder().decode([String: [String: Double]].self, from: data) {
                    let updatedCoins = decodedResponse.compactMap { (key, value) -> CryptoCoin? in
                        guard let price = value["usd"], let ticker = tickerMapping[key] else { return nil }
                        return CryptoCoin(name: key.capitalized, ticker: ticker, price: price, previousPrice: nil)
                    }.sorted(by: { $0.name < $1.name })

                    DispatchQueue.main.async {
                        cryptoCoins = updatedCoins
                    }
                }
            }
        }.resume()
        
        // ✅ Fetch remaining cryptos in background
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 5) {
            let remainingCoinIDs = tickerMapping.keys.dropFirst(100).joined(separator: ",")
            let urlString = "https://api.coingecko.com/api/v3/simple/price?ids=\(remainingCoinIDs)&vs_currencies=usd"

            guard let url = URL(string: urlString) else { return }

            URLSession.shared.dataTask(with: url) { data, _, error in
                guard let data = data, error == nil else { return }

                DispatchQueue.global(qos: .background).async {
                    if let decodedResponse = try? JSONDecoder().decode([String: [String: Double]].self, from: data) {
                        let moreCoins = decodedResponse.compactMap { (key, value) -> CryptoCoin? in
                            guard let price = value["usd"], let ticker = tickerMapping[key] else { return nil }
                            return CryptoCoin(name: key.capitalized, ticker: ticker, price: price, previousPrice: nil)
                        }

                        DispatchQueue.main.async {
                            cryptoCoins.append(contentsOf: moreCoins.sorted(by: { $0.name < $1.name }))
                        }
                    }
                }
            }.resume()
        }
    }
    
    func fetchTweets(for ticker: String) {
        // Construct the query: make a hashtag from the ticker (e.g., "#BTC")
        let query = "%23\(ticker)"  // URL-encoded hashtag: '#' becomes '%23'
        // Specify the fields you want to retrieve (e.g., creation time)
        let urlString = "https://api.twitter.com/2/tweets/search/recent?query=\(query)&tweet.fields=created_at"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL for tweets")
            return
        }
        
        // Set up the request with your Bearer Token
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        // Replace YOUR_BEARER_TOKEN with your actual token
        request.setValue("Bearer AAAAAAAAAAAAAAAAAAAAAPq8yAEAAAAAsirUb6FEEn1JOGy3P5EdtSAPTSU%3D0PgxgMwBxtmBTN3kw5zAxucSabhUVTyenXgs6aTF2dKWcxJnO4", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching tweets: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                if let httpResponse = response as? HTTPURLResponse {
                    print("HTTP Status Code: \(httpResponse.statusCode)")
                    if httpResponse.statusCode == 429 {
                        print("Rate limit reached. Please try again later.")
                    }
                }
                return
            }
            
            guard let data = data else {
                print("No tweet data returned")
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON: \(jsonString)")
            }
            
            do {
                let apiResponse = try JSONDecoder().decode(TwitterAPIResponse.self, from: data)
                DispatchQueue.main.async {
                    self.tweets = apiResponse.data ?? []
                    print("Fetched tweets: \(self.tweets)")
                }
            } catch {
                print("Error decoding tweet data: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func fetchWatchlistPrices() {
        let coinIDs = watchlist.compactMap { coin in
            tickerMapping.first(where: { $0.value == coin.ticker })?.key
        }.joined(separator: ",")

        let urlString = "https://api.coingecko.com/api/v3/simple/price?ids=\(coinIDs)&vs_currencies=usd"

        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
            if let jsonString = String(data: data, encoding: .utf8) {
                print("🔹 Received JSON: \(jsonString)")
            }
            DispatchQueue.global(qos: .background).async {
                do {
                    
                    let decodedResponse = try JSONDecoder().decode([String: [String: Double]].self, from: data)
                    var updatedWatchlist = watchlist

                    for i in updatedWatchlist.indices {
                        if let coinGeckoID = tickerMapping.first(where: { $0.value == updatedWatchlist[i].ticker })?.key,
                           let latestPrice = decodedResponse[coinGeckoID]?["usd"],
                           latestPrice != updatedWatchlist[i].price {

                            let newEntry = PriceEntry(price: latestPrice, date: Date())
                            updatedWatchlist[i].priceHistory.append(newEntry)
                            updatedWatchlist[i].previousPrice = updatedWatchlist[i].price
                            updatedWatchlist[i].price = latestPrice
                        }
                    }

                    DispatchQueue.main.async {
                        watchlist = updatedWatchlist
                        saveWatchlist()
                    }
                } catch {
                    print("❌ JSON Decoding Error: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
    
    func fetchCryptoPrices() {
        let coinIDs = tickerMapping.keys.joined(separator: ",") // ✅ Joins all keys from tickerMapping
        let urlString = "https://api.coingecko.com/api/v3/simple/price?ids=\(coinIDs)&vs_currencies=usd"
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("❌ Network Error: \(error?.localizedDescription ?? "No error description.")")
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("🔹 Received JSON: \(jsonString)")
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode([String: [String: Double]].self, from: data)
                DispatchQueue.main.async {
                    var updatedCoins: [CryptoCoin] = []
                    
                    for (key, value) in decodedResponse {
                        guard let price = value["usd"], let ticker = tickerMapping[key] else { continue }
                        
                        let previousCoin = cryptoCoins.first(where: { $0.ticker == ticker })
                        let previousPrice = previousCoin?.price
                        
                        updatedCoins.append(CryptoCoin(
                            name: key.capitalized,
                            ticker: ticker,
                            price: price,
                            previousPrice: previousPrice
                        ))
                    }
                    
                    cryptoCoins = updatedCoins.sorted { $0.name < $1.name }
                    print("✅ Prices updated successfully: \(cryptoCoins.count) coins loaded.")
                }
            } catch {
                print("❌ JSON Decoding Error: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func formattedTodayDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE MMMM d" // Example: "Monday, March 6"
        return formatter.string(from: Date())
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    func saveWatchlist() {
        if let encoded = try? JSONEncoder().encode(watchlist) {
            storedWatchlist = encoded
        }
    }
    
    func loadWatchlist() {
        if let decodedWatchlist = try? JSONDecoder().decode([CryptoCoin].self, from: storedWatchlist) {
            watchlist = decodedWatchlist.map { savedCoin in
                var updatedCoin = savedCoin

                // Ensure price history is not empty
                if updatedCoin.priceHistory.isEmpty {
                    print("⚠️ No price history found for \(updatedCoin.ticker), adding latest price.")
                    updatedCoin.priceHistory.append(PriceEntry(price: updatedCoin.price, date: Date()))
                } else {
                    print("✅ Loaded price history for \(updatedCoin.ticker): \(updatedCoin.priceHistory)")
                }
                return updatedCoin
            }
            print("🔄 Watchlist loaded successfully: \(watchlist)")
        } else {
            print("⚠️ No saved watchlist found.")
        }
    }
}

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true // ✅ Enable JavaScript

        let webView = WKWebView(frame: .zero, configuration: config)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

// Add this struct at the top of your file (e.g., below your imports)
struct Candlestick: Identifiable {
    let id = UUID()
    let time: Date
    let open: Double
    let close: Double
    let high: Double
    let low: Double
}

#Preview {
    ContentView()
}
