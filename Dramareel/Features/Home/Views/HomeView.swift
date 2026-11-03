import SwiftUI

public struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @ObservedObject var authService: AuthService = .shared
    
    public let onSelectDrama: (Drama) -> Void
    public let onPlayDrama: (Drama, Episode?) -> Void
    public let onOpenStore: () -> Void
    
    @State private var isShowingSearch: Bool = false
    
    public init(
        onSelectDrama: @escaping (Drama) -> Void,
        onPlayDrama: @escaping (Drama, Episode?) -> Void,
        onOpenStore: @escaping () -> Void
    ) {
        self.onSelectDrama = onSelectDrama
        self.onPlayDrama = onPlayDrama
        self.onOpenStore = onOpenStore
    }
    
    public var body: some View {
        ZStack {
            DramareelColors.backgroundDark
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Custom Header
                headerBar
                
                if viewModel.isLoading && viewModel.allDramas.isEmpty {
                    LoadingStateView(message: "Discovering Dramas...")
                } else if let error = viewModel.errorMessage, viewModel.allDramas.isEmpty {
                    ErrorStateView(title: "Connection Failed", message: error) {
                        Task { await viewModel.loadHomeData() }
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            // Category Filter Bar
                            GenreFilterBar(
                                categories: viewModel.categories,
                                selectedCategory: $viewModel.selectedCategory
                            )
                            .padding(.top, 8)
                            
                            if viewModel.selectedCategory == "All" {
                                // Default Home Feed with Sections
                                
                                // Hero Carousel
                                if !viewModel.featuredDramas.isEmpty {
                                    FeaturedHeroSlider(
                                        dramas: viewModel.featuredDramas,
                                        onSelectDrama: onSelectDrama,
                                        onPlayDrama: { drama in
                                            onPlayDrama(drama, nil)
                                        }
                                    )
                                }
                                
                                // Trending Section
                                DramaRowView(
                                    title: "Trending Now",
                                    icon: "flame.fill",
                                    dramas: viewModel.trendingDramas,
                                    onSelectDrama: onSelectDrama
                                )
                                
                                // Popular Section
                                DramaRowView(
                                    title: "Most Popular",
                                    icon: "heart.fill",
                                    dramas: viewModel.popularDramas,
                                    onSelectDrama: onSelectDrama
                                )
                                
                                // Recent Releases Section
                                DramaRowView(
                                    title: "New Releases",
                                    icon: "sparkles",
                                    dramas: viewModel.recentDramas,
                                    onSelectDrama: onSelectDrama
                                )
                            } else {
                                // Filtered Grid for selected category
                                let filtered = viewModel.filteredDramasByCategory
                                if filtered.isEmpty {
                                    EmptyStateView(
                                        icon: "film",
                                        title: "No Dramas",
                                        message: "No series currently tagged under \(viewModel.selectedCategory)."
                                    )
                                    .padding(.top, 40)
                                } else {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("\(viewModel.selectedCategory) Dramas")
                                            .font(DramareelTypography.sectionTitle(size: 18))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 16)
                                        
                                        let columns = [
                                            GridItem(.flexible(), spacing: 12),
                                            GridItem(.flexible(), spacing: 12),
                                            GridItem(.flexible(), spacing: 12)
                                        ]
                                        
                                        LazyVGrid(columns: columns, spacing: 14) {
                                            ForEach(filtered) { drama in
                                                DramaPosterCard(drama: drama, width: 110, height: 160) {
                                                    onSelectDrama(drama)
                                                }
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                    }
                                    .padding(.top, 10)
                                }
                            }
                            
                            Spacer().frame(height: 70)
                        }
                    }
                    .refreshable {
                        await viewModel.loadHomeData()
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingSearch) {
            DramaSearchView(viewModel: viewModel, onSelectDrama: onSelectDrama)
        }
        .task {
            if viewModel.allDramas.isEmpty {
                await viewModel.loadHomeData()
            }
        }
    }
    
    // Top Bar
    private var headerBar: some View {
        HStack {
            DramareelLogoView(size: 32, showWordmark: true, showSlogan: false)
            
            Spacer()
            
            // Coin Balance Pill
            Button(action: onOpenStore) {
                HStack(spacing: 5) {
                    Image(systemName: "circle.circle.fill")
                        .font(.system(size: 13))
                        .foregroundColor(DramareelColors.coinGold)
                    Text("\(authService.currentUser?.coins ?? 0)")
                        .font(DramareelTypography.tag(size: 12))
                        .foregroundColor(.white)
                    Image(systemName: "plus")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(DramareelColors.coinGold)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(DramareelColors.surfaceCard)
                .cornerRadius(20)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(DramareelColors.coinGold.opacity(0.4), lineWidth: 1))
            }
            
            // Search Button
            Button(action: { isShowingSearch = true }) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(DramareelColors.surfaceCard)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(DramareelColors.surfaceBorder, lineWidth: 1))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(DramareelColors.backgroundDark.opacity(0.95))
    }
}
