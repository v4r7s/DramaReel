import SwiftUI

public struct VideoPlayerScreenView: View {
    @StateObject private var viewModel: VideoPlayerViewModel
    public let onDismiss: () -> Void
    public let onWatchAdRequested: (Episode) -> Void
    public let onOpenStore: () -> Void
    
    public init(
        drama: Drama,
        episodes: [Episode],
        initialEpisode: Episode,
        onDismiss: @escaping () -> Void,
        onWatchAdRequested: @escaping (Episode) -> Void,
        onOpenStore: @escaping () -> Void
    ) {
        self._viewModel = StateObject(
            wrappedValue: VideoPlayerViewModel(
                drama: drama,
                episodes: episodes,
                initialEpisode: initialEpisode
            )
        )
        self.onDismiss = onDismiss
        self.onWatchAdRequested = onWatchAdRequested
        self.onOpenStore = onOpenStore
    }
    
    public var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            // Video Layer
            DramareelPlayerView(player: viewModel.playerEngine.player)
                .ignoresSafeArea()
                .onTapGesture {
                    viewModel.toggleControls()
                }
            
            // Watermark Layer
            if viewModel.watermarkSettings.enabled {
                WatermarkOverlayView(
                    urlString: viewModel.watermarkSettings.url,
                    position: viewModel.watermarkSettings.position,
                    opacity: viewModel.watermarkSettings.opacity
                )
            }
            
            // Controls Overlay
            if viewModel.isControlsVisible {
                PlayerControlsOverlay(viewModel: viewModel) {
                    viewModel.saveCurrentProgress()
                    onDismiss()
                }
                .transition(.opacity)
            }
            
            // Playback Error Overlay
            if let error = viewModel.playerEngine.playbackError {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(DramareelColors.errorRed)
                    Text("Streaming Error")
                        .font(DramareelTypography.sectionTitle(size: 16))
                        .foregroundColor(.white)
                    Text(error)
                        .font(DramareelTypography.body(size: 12))
                        .foregroundColor(DramareelColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    DramareelButton(title: "Retry", icon: "arrow.clockwise", style: .primaryGradient, isFullWidth: false) {
                        viewModel.startPlayingCurrentEpisode()
                    }
                    .padding(.top, 6)
                }
                .padding(24)
                .background(DramareelColors.surfaceCard.opacity(0.95))
                .cornerRadius(16)
                .padding(24)
            }
        }
        .statusBarHidden(!viewModel.isControlsVisible)
        .sheet(isPresented: $viewModel.isShowingSubtitleSheet) {
            SubtitleSelectionSheet(
                availableSubtitles: viewModel.playerEngine.availableSubtitles,
                selectedSubtitle: viewModel.playerEngine.selectedSubtitle
            ) { name in
                viewModel.playerEngine.selectSubtitle(named: name)
            }
        }
        .sheet(isPresented: $viewModel.isShowingEpisodesSheet) {
            episodesDrawer
        }
        .onDisappear {
            viewModel.saveCurrentProgress()
            viewModel.playerEngine.cleanup()
        }
    }
    
    private var episodesDrawer: some View {
        ZStack {
            DramareelColors.surfaceCard
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Select Episode")
                        .font(DramareelTypography.sectionTitle(size: 18))
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: { viewModel.isShowingEpisodesSheet = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(DramareelColors.textMuted)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                EpisodeGridView(
                    episodes: viewModel.episodes,
                    currentlyPlayingEpisodeId: viewModel.currentEpisode.id,
                    isEpisodeUnlocked: { ep in
                        !ep.isPremium ||
                        LocalStorageManager.shared.getUnlockedEpisodeIds().contains(ep.id)
                    },
                    onSelectEpisode: { episode in
                        viewModel.isShowingEpisodesSheet = false
                        viewModel.selectEpisode(episode)
                    }
                )
                
                Spacer()
            }
        }
        .presentationDetents([.medium, .large])
    }
}
