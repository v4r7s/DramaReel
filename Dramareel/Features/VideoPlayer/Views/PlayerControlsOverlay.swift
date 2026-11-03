import SwiftUI

public struct PlayerControlsOverlay: View {
    @ObservedObject var viewModel: VideoPlayerViewModel
    public let onDismiss: () -> Void
    
    public init(viewModel: VideoPlayerViewModel, onDismiss: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        ZStack {
            // Dark gradient scrim when controls are active
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    viewModel.toggleControls()
                }
            
            VStack {
                // Top Bar
                HStack(spacing: 12) {
                    Button(action: onDismiss) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.4))
                            .clipShape(Circle())
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(viewModel.drama.title)
                            .font(DramareelTypography.dramaTitle(size: 15))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Text("Episode \(viewModel.currentEpisode.episodeNumber): \(viewModel.currentEpisode.title)")
                            .font(DramareelTypography.caption(size: 12))
                            .foregroundColor(DramareelColors.textSecondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    // Subtitles Button
                    Button(action: { viewModel.isShowingSubtitleSheet = true }) {
                        Image(systemName: "captions.bubble.fill")
                            .font(.system(size: 16))
                            .foregroundColor(viewModel.playerEngine.selectedSubtitle != nil ? DramareelColors.electricCyan : .white)
                            .padding(8)
                            .background(Color.black.opacity(0.4))
                            .clipShape(Circle())
                    }
                    
                    // Episodes Drawer Button
                    Button(action: { viewModel.isShowingEpisodesSheet = true }) {
                        Image(systemName: "square.grid.2x2.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.4))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                
                Spacer()
                
                // Center Controls
                HStack(spacing: 40) {
                    // Rewind 10s
                    Button(action: {
                        viewModel.playerEngine.seek(to: max(0, viewModel.playerEngine.currentTime - 10))
                    }) {
                        Image(systemName: "gobackward.10")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                    }
                    
                    // Play / Pause or Buffering
                    if viewModel.playerEngine.isBuffering {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.6)
                            .frame(width: 56, height: 56)
                    } else {
                        Button(action: {
                            viewModel.playerEngine.togglePlayPause()
                        }) {
                            Image(systemName: viewModel.playerEngine.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.white)
                                .frame(width: 64, height: 64)
                                .background(DramareelColors.actionGradient)
                                .clipShape(Circle())
                                .shadow(color: DramareelColors.neonPink.opacity(0.5), radius: 10, x: 0, y: 0)
                        }
                    }
                    
                    // Forward 10s
                    Button(action: {
                        viewModel.playerEngine.seek(to: min(viewModel.playerEngine.duration, viewModel.playerEngine.currentTime + 10))
                    }) {
                        Image(systemName: "goforward.10")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
                
                // Bottom Timeline Scrubber
                VStack(spacing: 6) {
                    HStack(spacing: 8) {
                        Text(formatTime(viewModel.playerEngine.currentTime))
                            .font(DramareelTypography.tag(size: 11))
                            .foregroundColor(.white)
                        
                        // Scrubber Slider
                        Slider(
                            value: Binding(
                                get: { viewModel.playerEngine.currentTime },
                                set: { viewModel.playerEngine.seek(to: $0) }
                            ),
                            in: 0...max(1, viewModel.playerEngine.duration)
                        )
                        .tint(DramareelColors.neonPink)
                        
                        Text(formatTime(viewModel.playerEngine.duration))
                            .font(DramareelTypography.tag(size: 11))
                            .foregroundColor(DramareelColors.textSecondary)
                        
                        // Next Episode Quick Button
                        Button(action: { viewModel.playNextEpisode() }) {
                            Image(systemName: "forward.end.fill")
                                .font(.system(size: 15))
                                .foregroundColor(.white)
                        }
                        .padding(.leading, 6)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
        }
    }
    
    private func formatTime(_ seconds: Double) -> String {
        guard seconds.isFinite && seconds >= 0 else { return "00:00" }
        let total = Int(seconds)
        let m = total / 60
        let s = total % 60
        return String(format: "%02d:%02d", m, s)
    }
}
