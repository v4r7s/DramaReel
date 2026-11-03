import SwiftUI

public struct WatchHistoryView: View {
    @ObservedObject var viewModel: UserAccountViewModel
    public let allDramas: [Drama]
    public let onSelectDrama: (Drama) -> Void
    
    public init(viewModel: UserAccountViewModel, allDramas: [Drama], onSelectDrama: @escaping (Drama) -> Void) {
        self.viewModel = viewModel
        self.allDramas = allDramas
        self.onSelectDrama = onSelectDrama
    }
    
    public var body: some View {
        ZStack {
            DramareelColors.backgroundDark
                .ignoresSafeArea()
            
            if viewModel.historyItems.isEmpty {
                EmptyStateView(
                    icon: "clock.arrow.circlepath",
                    title: "No Watch History",
                    message: "Dramas and episodes you stream will appear here so you can continue where you left off."
                )
            } else {
                List {
                    ForEach(viewModel.historyItems) { item in
                        let drama = allDramas.first(where: { $0.id == item.seriesId })
                        
                        Button(action: {
                            if let drama = drama {
                                onSelectDrama(drama)
                            }
                        }) {
                            HStack(spacing: 12) {
                                // Cover
                                AsyncImage(url: drama?.displayCoverUrl) { phase in
                                    if let image = phase.image {
                                        image.resizable().scaledToFill()
                                    } else {
                                        DramareelColors.surfaceCard
                                    }
                                }
                                .frame(width: 55, height: 75)
                                .cornerRadius(8)
                                .clipped()
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(drama?.title ?? "Drama Series")
                                        .font(DramareelTypography.dramaTitle(size: 14))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                    
                                    Text("Episode \(item.episodeInSeason)")
                                        .font(DramareelTypography.caption(size: 12))
                                        .foregroundColor(DramareelColors.neonPink)
                                    
                                    Text("Watched recently")
                                        .font(DramareelTypography.tag(size: 10))
                                        .foregroundColor(DramareelColors.textMuted)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(DramareelColors.electricCyan)
                            }
                            .padding(.vertical, 4)
                        }
                        .listRowBackground(DramareelColors.surfaceCard)
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("Watch History")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !viewModel.historyItems.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear") {
                        Task { await viewModel.clearWatchHistory() }
                    }
                    .foregroundColor(DramareelColors.errorRed)
                }
            }
        }
    }
}

public struct FavoritesView: View {
    @ObservedObject var viewModel: UserAccountViewModel
    public let onSelectDrama: (Drama) -> Void
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    public init(viewModel: UserAccountViewModel, onSelectDrama: @escaping (Drama) -> Void) {
        self.viewModel = viewModel
        self.onSelectDrama = onSelectDrama
    }
    
    public var body: some View {
        ZStack {
            DramareelColors.backgroundDark
                .ignoresSafeArea()
            
            if viewModel.favoriteDramas.isEmpty {
                EmptyStateView(
                    icon: "bookmark",
                    title: "No Saved Dramas",
                    message: "Tap the bookmark icon on any drama page to save it to your personal watchlist."
                )
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(viewModel.favoriteDramas) { drama in
                            DramaPosterCard(drama: drama, width: 110, height: 160) {
                                onSelectDrama(drama)
                            }
                        }
                    }
                    .padding(16)
                }
            }
        }
        .navigationTitle("My Watchlist")
        .navigationBarTitleDisplayMode(.inline)
    }
}

public struct TransactionHistoryView: View {
    @ObservedObject var viewModel: UserAccountViewModel
    
    public init(viewModel: UserAccountViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ZStack {
            DramareelColors.backgroundDark
                .ignoresSafeArea()
            
            if viewModel.transactions.isEmpty {
                EmptyStateView(
                    icon: "list.bullet.rectangle.portrait",
                    title: "No Transactions",
                    message: "Your coin purchases, check-in earnings, and episode unlocks will appear here."
                )
            } else {
                List {
                    ForEach(viewModel.transactions) { item in
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(item.isPositive ? DramareelColors.successGreen.opacity(0.15) : DramareelColors.errorRed.opacity(0.15))
                                    .frame(width: 36, height: 36)
                                Image(systemName: item.isPositive ? "arrow.down.left" : "arrow.up.right")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(item.isPositive ? DramareelColors.successGreen : DramareelColors.errorRed)
                            }
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text(item.description)
                                    .font(DramareelTypography.dramaTitle(size: 13))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                
                                Text(item.type.capitalized)
                                    .font(DramareelTypography.tag(size: 10))
                                    .foregroundColor(DramareelColors.textMuted)
                            }
                            
                            Spacer()
                            
                            Text("\(item.isPositive ? "+" : "")\(item.amount) Coins")
                                .font(DramareelTypography.button(size: 13))
                                .foregroundColor(item.isPositive ? DramareelColors.coinGold : DramareelColors.textSecondary)
                        }
                        .padding(.vertical, 4)
                        .listRowBackground(DramareelColors.surfaceCard)
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("Coin Transactions")
        .navigationBarTitleDisplayMode(.inline)
    }
}
