import SwiftUI

public enum AppTab: Int, CaseIterable {
    case home = 0
    case shorts = 1
    case rewards = 2
    case profile = 3
    
    public var title: String {
        switch self {
        case .home: return "Home"
        case .shorts: return "Shorts"
        case .rewards: return "Rewards"
        case .profile: return "Profile"
        }
    }
    
    public var icon: String {
        switch self {
        case .home: return "sparkles.tv.fill"
        case .shorts: return "play.rectangle.on.rectangle.fill"
        case .rewards: return "gift.fill"
        case .profile: return "person.crop.circle.fill"
        }
    }
}

public struct MainTabView: View {
    @State private var selectedTab: AppTab = .home
    @State private var selectedDrama: Drama? = nil
    @State private var activePlayback: (drama: Drama, episode: Episode)? = nil
    @State private var isShowingStore: Bool = false
    @State private var isShowingLogin: Bool = false
    @State private var isShowingOnboarding: Bool = false
    
    @ObservedObject var authService: AuthService = .shared
    @StateObject private var homeVM = HomeViewModel()
    
    public init() {}
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            // Tab Content
            TabView(selection: $selectedTab) {
                HomeView(
                    onSelectDrama: { drama in
                        selectedDrama = drama
                    },
                    onPlayDrama: { drama, episode in
                        playDrama(drama: drama, episode: episode)
                    },
                    onOpenStore: { isShowingStore = true }
                )
                .tag(AppTab.home)
                
                ShortsFeedView(
                    onSelectDrama: { drama in
                        selectedDrama = drama
                    },
                    onPlayDrama: { drama, episode in
                        playDrama(drama: drama, episode: episode)
                    }
                )
                .tag(AppTab.shorts)
                
                RewardsView(
                    onWatchAdReward: { onEarned in
                        presentRewardedAd(onEarned: onEarned)
                    }
                )
                .tag(AppTab.rewards)
                
                ProfileView(
                    allDramas: homeVM.allDramas,
                    onSelectDrama: { drama in
                        selectedDrama = drama
                    },
                    onOpenStore: { isShowingStore = true },
                    onOpenLogin: { isShowingLogin = true }
                )
                .tag(AppTab.profile)
            }
            .ignoresSafeArea(.keyboard)
            
            // Custom Floating Glass Tab Bar
            customTabBar
        }
        .sheet(item: $selectedDrama) { drama in
            NavigationStack {
                DramaDetailView(
                    drama: drama,
                    onPlayEpisode: { drama, episode in
                        selectedDrama = nil
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            playDrama(drama: drama, episode: episode)
                        }
                    },
                    onWatchAdRequested: { episode in
                        presentRewardedAd {
                            // On ad completed, unlock episode
                            Task {
                                let vm = DramaDetailViewModel(drama: drama)
                                _ = await vm.unlockWithAd(episode: episode)
                            }
                        }
                    },
                    onOpenStore: { isShowingStore = true }
                )
            }
        }
        .fullScreenCover(item: Binding(
            get: { activePlayback.map { PlaybackIdentifier(drama: $0.drama, episode: $0.episode) } },
            set: { _ in activePlayback = nil }
        )) { item in
            VideoPlayerScreenView(
                drama: item.drama,
                episodes: [item.episode],
                initialEpisode: item.episode,
                onDismiss: { activePlayback = nil },
                onWatchAdRequested: { ep in
                    presentRewardedAd {
                        Task {
                            let vm = DramaDetailViewModel(drama: item.drama)
                            _ = await vm.unlockWithAd(episode: ep)
                        }
                    }
                },
                onOpenStore: { isShowingStore = true }
            )
        }
        .sheet(isPresented: $isShowingStore) {
            StoreView()
        }
        .sheet(isPresented: $isShowingLogin) {
            LoginView()
        }
        .fullScreenCover(isPresented: $isShowingOnboarding) {
            OnboardingView(isPresented: $isShowingOnboarding)
        }
        .onAppear {
            let hasSeen = UserDefaults.standard.bool(forKey: AppConstants.StorageKeys.hasCompletedOnboarding)
            if !hasSeen {
                isShowingOnboarding = true
            }
            AdManager.shared.initialize()
        }
    }
    
    // Custom Glass Tab Bar
    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                let isSelected = tab == selectedTab
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 20, weight: isSelected ? .bold : .regular))
                            .foregroundStyle(
                                isSelected ?
                                AnyShapeStyle(LinearGradient(colors: [DramareelColors.neonPink, DramareelColors.electricCyan], startPoint: .topLeading, endPoint: .bottomTrailing)) :
                                AnyShapeStyle(DramareelColors.textMuted)
                            )
                        
                        Text(tab.title)
                            .font(DramareelTypography.tag(size: 10))
                            .foregroundColor(isSelected ? .white : DramareelColors.textMuted)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 22)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(DramareelColors.surfaceCard.opacity(0.92))
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(DramareelColors.surfaceGlass.opacity(0.5))
                        .blur(radius: 12)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(DramareelColors.surfaceBorder.opacity(0.6), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.5), radius: 16, x: 0, y: 4)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 6)
    }
    
    private func playDrama(drama: Drama, episode: Episode?) {
        if let episode = episode {
            activePlayback = (drama, episode)
        } else {
            // Fetch episodes then play episode 1
            Task {
                do {
                    let eps: [Episode] = try await APIClient.shared.request(.episodes(seriesId: drama.id))
                    if let first = eps.first {
                        activePlayback = (drama, first)
                    }
                } catch {
                    #if DEBUG
                    print("Failed to fetch episode for play: \(error)")
                    #endif
                }
            }
        }
    }
    
    private func presentRewardedAd(onEarned: @escaping () -> Void) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            return
        }
        
        AdManager.shared.showRewardedAd(
            from: rootVC,
            onRewarded: onEarned
        )
    }
}

// Wrapper for playback presentation item
struct PlaybackIdentifier: Identifiable {
    var id: String { "\(drama.id)_\(episode.id)" }
    let drama: Drama
    let episode: Episode
}
