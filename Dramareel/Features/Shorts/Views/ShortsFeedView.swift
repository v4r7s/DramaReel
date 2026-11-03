import SwiftUI
import AVFoundation

public struct ShortReelItemView: View {
    public let item: ShortItem
    public let isCurrent: Bool
    public let isMuted: Bool
    public let isLiked: Bool
    public let onToggleMute: () -> Void
    public let onToggleLike: () -> Void
    public let onSelectDrama: (Drama) -> Void
    public let onPlayDrama: (Drama, Episode) -> Void
    
    @StateObject private var engine = DramareelPlayerEngine()
    @State private var isPlaying: Bool = true
    
    public init(
        item: ShortItem,
        isCurrent: Bool,
        isMuted: Bool,
        isLiked: Bool,
        onToggleMute: @escaping () -> Void,
        onToggleLike: @escaping () -> Void,
        onSelectDrama: @escaping (Drama) -> Void,
        onPlayDrama: @escaping (Drama, Episode) -> Void
    ) {
        self.item = item
        self.isCurrent = isCurrent
        self.isMuted = isMuted
        self.isLiked = isLiked
        self.onToggleMute = onToggleMute
        self.onToggleLike = onToggleLike
        self.onSelectDrama = onSelectDrama
        self.onPlayDrama = onPlayDrama
    }
    
    public var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            // Video Player
            DramareelPlayerView(player: engine.player)
                .ignoresSafeArea()
                .onTapGesture {
                    engine.togglePlayPause()
                    isPlaying = engine.isPlaying
                }
            
            // Right-Side Action Sidebar
            HStack {
                Spacer()
                VStack(spacing: 20) {
                    Spacer()
                    
                    // Like Action
                    Button(action: onToggleLike) {
                        VStack(spacing: 4) {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .font(.system(size: 26))
                                .foregroundColor(isLiked ? DramareelColors.neonPink : .white)
                            Text("\(item.drama.likes + (isLiked ? 1 : 0))")
                                .font(DramareelTypography.tag(size: 11))
                                .foregroundColor(.white)
                        }
                    }
                    
                    // Details Action
                    Button(action: { onSelectDrama(item.drama) }) {
                        VStack(spacing: 4) {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 26))
                                .foregroundColor(.white)
                            Text("Details")
                                .font(DramareelTypography.tag(size: 11))
                                .foregroundColor(.white)
                        }
                    }
                    
                    // Mute / Unmute Action
                    Button(action: {
                        onToggleMute()
                        engine.player?.isMuted = !isMuted
                    }) {
                        Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.black.opacity(0.45))
                            .clipShape(Circle())
                    }
                    
                    Spacer().frame(height: 90)
                }
                .padding(.trailing, 14)
            }
            
            // Bottom Metadata Overlay
            VStack {
                Spacer()
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 6) {
                        // Title
                        Text(item.drama.title)
                            .font(DramareelTypography.heroTitle(size: 18))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.8), radius: 4, x: 0, y: 1)
                        
                        // Synopsis
                        Text(item.drama.description)
                            .font(DramareelTypography.body(size: 12))
                            .foregroundColor(DramareelColors.textSecondary)
                            .lineLimit(2)
                            .shadow(color: .black.opacity(0.8), radius: 4, x: 0, y: 1)
                        
                        // Watch Full Series Button
                        Button(action: { onPlayDrama(item.drama, item.episode) }) {
                            HStack(spacing: 6) {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 12, weight: .bold))
                                Text("Watch Episode \(item.episode.episodeNumber)")
                                    .font(DramareelTypography.button(size: 13))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(DramareelColors.actionGradient)
                            .cornerRadius(20)
                            .shadow(color: DramareelColors.neonPink.opacity(0.4), radius: 6, x: 0, y: 2)
                        }
                        .padding(.top, 4)
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 90)
            }
        }
        .onChange(of: isCurrent) { current in
            if current {
                engine.loadVideo(urlString: item.episode.videoUrl)
                engine.player?.isMuted = isMuted
            } else {
                engine.pause()
            }
        }
        .onAppear {
            if isCurrent {
                engine.loadVideo(urlString: item.episode.videoUrl)
                engine.player?.isMuted = isMuted
            }
        }
        .onDisappear {
            engine.cleanup()
        }
    }
}

public struct ShortsFeedView: View {
    @StateObject private var viewModel = ShortsViewModel()
    public let onSelectDrama: (Drama) -> Void
    public let onPlayDrama: (Drama, Episode) -> Void
    
    public init(
        onSelectDrama: @escaping (Drama) -> Void,
        onPlayDrama: @escaping (Drama, Episode) -> Void
    ) {
        self.onSelectDrama = onSelectDrama
        self.onPlayDrama = onPlayDrama
    }
    
    public var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            if viewModel.isLoading && viewModel.shorts.isEmpty {
                LoadingStateView(message: "Loading Shorts Feed...")
            } else if let error = viewModel.errorMessage, viewModel.shorts.isEmpty {
                ErrorStateView(title: "Failed to Load Shorts", message: error) {
                    Task { await viewModel.loadShorts() }
                }
            } else if viewModel.shorts.isEmpty {
                EmptyStateView(
                    icon: "play.tv",
                    title: "No Shorts Yet",
                    message: "Check back soon for new short drama clips and teasers."
                )
            } else {
                TabView(selection: $viewModel.currentIndex) {
                    ForEach(0..<viewModel.shorts.count, id: \.self) { index in
                        let item = viewModel.shorts[index]
                        ShortReelItemView(
                            item: item,
                            isCurrent: index == viewModel.currentIndex,
                            isMuted: viewModel.isMuted,
                            isLiked: viewModel.likedDramaIds.contains(item.drama.id),
                            onToggleMute: { viewModel.isMuted.toggle() },
                            onToggleLike: {
                                Task { await viewModel.toggleLike(dramaId: item.drama.id) }
                            },
                            onSelectDrama: onSelectDrama,
                            onPlayDrama: onPlayDrama
                        )
                        .tag(index)
                        .rotationEffect(.degrees(-90))
                        .frame(
                            width: UIScreen.main.bounds.height,
                            height: UIScreen.main.bounds.width
                        )
                    }
                }
                .rotationEffect(.degrees(90))
                .frame(
                    width: UIScreen.main.bounds.width,
                    height: UIScreen.main.bounds.height
                )
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
        }
        .task {
            await viewModel.loadShorts()
        }
    }
}
