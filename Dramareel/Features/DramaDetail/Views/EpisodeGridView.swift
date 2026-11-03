import SwiftUI

public struct EpisodeGridView: View {
    public let episodes: [Episode]
    public let currentlyPlayingEpisodeId: String?
    public let isEpisodeUnlocked: (Episode) -> Bool
    public let onSelectEpisode: (Episode) -> Void
    
    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    public init(
        episodes: [Episode],
        currentlyPlayingEpisodeId: String? = nil,
        isEpisodeUnlocked: @escaping (Episode) -> Bool,
        onSelectEpisode: @escaping (Episode) -> Void
    ) {
        self.episodes = episodes
        self.currentlyPlayingEpisodeId = currentlyPlayingEpisodeId
        self.isEpisodeUnlocked = isEpisodeUnlocked
        self.onSelectEpisode = onSelectEpisode
    }
    
    public var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(episodes) { episode in
                let unlocked = isEpisodeUnlocked(episode)
                let isPlaying = episode.id == currentlyPlayingEpisodeId
                
                Button(action: { onSelectEpisode(episode) }) {
                    ZStack(alignment: .topTrailing) {
                        VStack(spacing: 2) {
                            if isPlaying {
                                Image(systemName: "waveform")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(DramareelColors.neonPink)
                            } else {
                                Text("\(episode.episodeNumber)")
                                    .font(DramareelTypography.button(size: 14))
                                    .foregroundColor(isPlaying ? DramareelColors.neonPink : .white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            isPlaying ?
                            AnyView(DramareelColors.surfaceGlass.opacity(0.9)) :
                            unlocked ?
                            AnyView(DramareelColors.surfaceCard) :
                            AnyView(DramareelColors.surfaceCard.opacity(0.6))
                        )
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    isPlaying ? DramareelColors.neonPink :
                                    unlocked ? DramareelColors.surfaceBorder :
                                    DramareelColors.surfaceBorder.opacity(0.4),
                                    lineWidth: isPlaying ? 1.5 : 1
                                )
                        )
                        
                        // Lock Icon or Coin Badge
                        if !unlocked {
                            HStack(spacing: 1) {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 8))
                                    .foregroundColor(DramareelColors.coinGold)
                            }
                            .padding(4)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }
}

public struct UnlockModalView: View {
    public let episode: Episode
    public let dramaTitle: String
    @ObservedObject var viewModel: DramaDetailViewModel
    @ObservedObject var authService: AuthService = .shared
    public let onWatchAdRequested: (Episode) -> Void
    public let onOpenStore: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var message: String? = nil
    
    public init(
        episode: Episode,
        dramaTitle: String,
        viewModel: DramaDetailViewModel,
        onWatchAdRequested: @escaping (Episode) -> Void,
        onOpenStore: @escaping () -> Void
    ) {
        self.episode = episode
        self.dramaTitle = dramaTitle
        self.viewModel = viewModel
        self.onWatchAdRequested = onWatchAdRequested
        self.onOpenStore = onOpenStore
    }
    
    public var body: some View {
        ZStack {
            DramareelColors.surfaceCard
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Top Grabber
                Capsule()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 40, height: 4)
                    .padding(.top, 12)
                
                // Header
                VStack(spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "lock.fill")
                            .foregroundColor(DramareelColors.coinGold)
                        Text("Unlock Episode \(episode.episodeNumber)")
                            .font(DramareelTypography.heroTitle(size: 20))
                            .foregroundColor(.white)
                    }
                    Text(dramaTitle)
                        .font(DramareelTypography.caption(size: 13))
                        .foregroundColor(DramareelColors.textSecondary)
                }
                
                // Current Coin Balance Card
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "circle.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(DramareelColors.coinGold)
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Your Balance")
                                .font(DramareelTypography.caption(size: 11))
                                .foregroundColor(DramareelColors.textSecondary)
                            Text("\(authService.currentUser?.coins ?? 0) Coins")
                                .font(DramareelTypography.button(size: 15))
                                .foregroundColor(.white)
                        }
                    }
                    Spacer()
                    Button(action: {
                        dismiss()
                        onOpenStore()
                    }) {
                        Text("Top Up")
                            .font(DramareelTypography.caption(size: 12))
                            .foregroundColor(DramareelColors.coinGold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(DramareelColors.coinGold.opacity(0.15))
                            .cornerRadius(12)
                    }
                }
                .padding(14)
                .background(DramareelColors.surfaceGlass)
                .cornerRadius(14)
                .padding(.horizontal, 20)
                
                if let message = message {
                    Text(message)
                        .font(DramareelTypography.caption(size: 12))
                        .foregroundColor(DramareelColors.errorRed)
                        .padding(.horizontal, 20)
                }
                
                // Unlock Options
                VStack(spacing: 12) {
                    // Option 1: Unlock with Coins
                    DramareelButton(
                        title: "Unlock for \(episode.coinCost) Coins",
                        icon: "bolt.fill",
                        style: .coinGold,
                        isLoading: viewModel.isUnlocking,
                        action: handleCoinsUnlock
                    )
                    
                    // Option 2: Watch Ad to Unlock
                    DramareelButton(
                        title: "Watch Ad to Unlock Free",
                        icon: "play.rectangle.fill",
                        style: .secondaryGlass,
                        isLoading: false,
                        action: {
                            dismiss()
                            onWatchAdRequested(episode)
                        }
                    )
                }
                .padding(.horizontal, 20)
                
                Spacer().frame(height: 10)
            }
        }
        .presentationDetents([.height(340)])
    }
    
    private func handleCoinsUnlock() {
        Task {
            let result = await viewModel.unlockWithCoins(episode: episode)
            if result.success {
                dismiss()
            } else {
                message = result.message
            }
        }
    }
}
