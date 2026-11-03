import SwiftUI

public struct DramaDetailView: View {
    public let drama: Drama
    @StateObject private var viewModel: DramaDetailViewModel
    public let onPlayEpisode: (Drama, Episode) -> Void
    public let onWatchAdRequested: (Episode) -> Void
    public let onOpenStore: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var isSynopsisExpanded: Bool = false
    
    public init(
        drama: Drama,
        onPlayEpisode: @escaping (Drama, Episode) -> Void,
        onWatchAdRequested: @escaping (Episode) -> Void,
        onOpenStore: @escaping () -> Void
    ) {
        self.drama = drama
        self._viewModel = StateObject(wrappedValue: DramaDetailViewModel(drama: drama))
        self.onPlayEpisode = onPlayEpisode
        self.onWatchAdRequested = onWatchAdRequested
        self.onOpenStore = onOpenStore
    }
    
    public var body: some View {
        ZStack {
            DramareelColors.backgroundDark
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    // Hero Backdrop & Cover Area
                    heroHeader
                    
                    // Metadata & Stats Row
                    metadataStatsRow
                    
                    // Action Buttons (Play / Favorite / Like / Share)
                    actionButtonsRow
                    
                    // Synopsis
                    synopsisSection
                    
                    // Episodes Grid Section
                    episodesSection
                    
                    Spacer().frame(height: 50)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
            }
        }
        .sheet(item: $viewModel.selectedEpisodeToUnlock) { episode in
            UnlockModalView(
                episode: episode,
                dramaTitle: drama.title,
                viewModel: viewModel,
                onWatchAdRequested: onWatchAdRequested,
                onOpenStore: onOpenStore
            )
        }
        .task {
            await viewModel.loadEpisodes()
        }
    }
    
    // MARK: - Hero Header
    private var heroHeader: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: drama.displayCoverUrl) { phase in
                switch phase {
                case .empty:
                    ShimmerView()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    DramareelColors.surfaceCard
                @unknown default:
                    DramareelColors.surfaceCard
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 320)
            .clipped()
            
            LinearGradient(
                colors: [
                    Color.clear,
                    DramareelColors.backgroundDark.opacity(0.6),
                    DramareelColors.backgroundDark
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 320)
            
            VStack(alignment: .leading, spacing: 6) {
                // Genres pills
                HStack(spacing: 6) {
                    ForEach(drama.genres.prefix(3), id: \.self) { genre in
                        Text(genre)
                            .font(DramareelTypography.tag(size: 9))
                            .foregroundColor(.white)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(DramareelColors.primaryPurple.opacity(0.8))
                            .cornerRadius(4)
                    }
                }
                
                Text(drama.title)
                    .font(DramareelTypography.heroTitle(size: 24))
                    .foregroundColor(.white)
                    .lineLimit(2)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 10)
        }
    }
    
    // MARK: - Metadata Row
    private var metadataStatsRow: some View {
        HStack(spacing: 16) {
            // Rating
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.system(size: 11))
                    .foregroundColor(DramareelColors.coinGold)
                Text(String(format: "%.1f", drama.rating))
                    .font(DramareelTypography.button(size: 13))
                    .foregroundColor(.white)
            }
            
            // Year
            Text("\(drama.releaseYear)")
                .font(DramareelTypography.caption(size: 12))
                .foregroundColor(DramareelColors.textSecondary)
            
            // Total Episodes
            Text("\(drama.totalEpisodes) Episodes")
                .font(DramareelTypography.caption(size: 12))
                .foregroundColor(DramareelColors.textSecondary)
            
            // Views
            HStack(spacing: 4) {
                Image(systemName: "eye.fill")
                    .font(.system(size: 11))
                    .foregroundColor(DramareelColors.textMuted)
                Text("\(drama.views) views")
                    .font(DramareelTypography.caption(size: 12))
                    .foregroundColor(DramareelColors.textSecondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Action Buttons
    private var actionButtonsRow: some View {
        HStack(spacing: 12) {
            // Play Episode 1
            Button(action: {
                if let first = viewModel.episodes.first {
                    handleEpisodeSelected(first)
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 15, weight: .bold))
                    Text("Watch Episode 1")
                        .font(DramareelTypography.button(size: 15))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(DramareelColors.actionGradient)
                .cornerRadius(12)
                .shadow(color: DramareelColors.neonPink.opacity(0.4), radius: 8, x: 0, y: 3)
            }
            
            // Bookmark / Favorite
            Button(action: {
                Task { await viewModel.toggleFavorite() }
            }) {
                VStack(spacing: 2) {
                    Image(systemName: viewModel.isFavorite ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 18))
                        .foregroundColor(viewModel.isFavorite ? DramareelColors.electricCyan : .white)
                    Text("Saved")
                        .font(DramareelTypography.tag(size: 9))
                        .foregroundColor(DramareelColors.textSecondary)
                }
                .frame(width: 52, height: 48)
                .background(DramareelColors.surfaceCard)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(DramareelColors.surfaceBorder, lineWidth: 1))
            }
            
            // Like
            Button(action: {
                Task { await viewModel.toggleLike() }
            }) {
                VStack(spacing: 2) {
                    Image(systemName: viewModel.isLiked ? "heart.fill" : "heart")
                        .font(.system(size: 18))
                        .foregroundColor(viewModel.isLiked ? DramareelColors.neonPink : .white)
                    Text("\(viewModel.likesCount)")
                        .font(DramareelTypography.tag(size: 9))
                        .foregroundColor(DramareelColors.textSecondary)
                }
                .frame(width: 52, height: 48)
                .background(DramareelColors.surfaceCard)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(DramareelColors.surfaceBorder, lineWidth: 1))
            }
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Synopsis
    private var synopsisSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Synopsis")
                .font(DramareelTypography.sectionTitle(size: 16))
                .foregroundColor(.white)
            
            Text(drama.description)
                .font(DramareelTypography.body(size: 13))
                .foregroundColor(DramareelColors.textSecondary)
                .lineLimit(isSynopsisExpanded ? nil : 3)
                .lineSpacing(2)
            
            if drama.description.count > 120 {
                Button(action: { withAnimation { isSynopsisExpanded.toggle() } }) {
                    Text(isSynopsisExpanded ? "Show Less" : "Read More")
                        .font(DramareelTypography.caption(size: 12))
                        .foregroundColor(DramareelColors.electricCyan)
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Episodes Section
    private var episodesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Episodes")
                    .font(DramareelTypography.sectionTitle(size: 16))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(viewModel.episodes.count) total")
                    .font(DramareelTypography.caption(size: 12))
                    .foregroundColor(DramareelColors.textSecondary)
            }
            .padding(.horizontal, 16)
            
            if viewModel.isLoading && viewModel.episodes.isEmpty {
                LoadingStateView(message: "Loading episodes...")
                    .frame(height: 120)
            } else {
                EpisodeGridView(
                    episodes: viewModel.episodes,
                    isEpisodeUnlocked: viewModel.isEpisodeUnlocked,
                    onSelectEpisode: handleEpisodeSelected
                )
            }
        }
    }
    
    private func handleEpisodeSelected(_ episode: Episode) {
        if viewModel.isEpisodeUnlocked(episode) {
            onPlayEpisode(drama, episode)
        } else {
            viewModel.selectedEpisodeToUnlock = episode
        }
    }
}
