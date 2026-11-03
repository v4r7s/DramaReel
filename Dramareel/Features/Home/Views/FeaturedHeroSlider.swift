import SwiftUI

public struct FeaturedHeroSlider: View {
    public let dramas: [Drama]
    public let onSelectDrama: (Drama) -> Void
    public let onPlayDrama: (Drama) -> Void
    
    @State private var currentIndex: Int = 0
    private let timer = Timer.publish(every: 4.5, on: .main, in: .common).autoconnect()
    
    public init(
        dramas: [Drama],
        onSelectDrama: @escaping (Drama) -> Void,
        onPlayDrama: @escaping (Drama) -> Void
    ) {
        self.dramas = dramas
        self.onSelectDrama = onSelectDrama
        self.onPlayDrama = onPlayDrama
    }
    
    public var body: some View {
        guard !dramas.isEmpty else { return AnyView(EmptyView()) }
        
        return AnyView(
            VStack(spacing: 8) {
                TabView(selection: $currentIndex) {
                    ForEach(0..<dramas.count, id: \.self) { index in
                        let drama = dramas[index]
                        
                        ZStack(alignment: .bottomLeading) {
                            // Poster Backdrop
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
                            .frame(height: 380)
                            .clipped()
                            
                            // Bottom Vignette & Scrim Gradient
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    DramareelColors.backgroundDark.opacity(0.4),
                                    DramareelColors.backgroundDark.opacity(0.95),
                                    DramareelColors.backgroundDark
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 380)
                            
                            // Content Overlay
                            VStack(alignment: .leading, spacing: 8) {
                                // Category & Rating Badges
                                HStack(spacing: 6) {
                                    Text(drama.category.uppercased())
                                        .font(DramareelTypography.tag(size: 9))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3.5)
                                        .background(DramareelColors.primaryPurple.opacity(0.8))
                                        .cornerRadius(4)
                                    
                                    HStack(spacing: 3) {
                                        Image(systemName: "star.fill")
                                            .font(.system(size: 8))
                                            .foregroundColor(DramareelColors.coinGold)
                                        Text(String(format: "%.1f", drama.rating))
                                            .font(DramareelTypography.tag(size: 9))
                                            .foregroundColor(.white)
                                    }
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3.5)
                                    .background(Color.black.opacity(0.6))
                                    .cornerRadius(4)
                                }
                                
                                // Drama Title
                                Text(drama.title)
                                    .font(DramareelTypography.heroTitle(size: 22))
                                    .foregroundColor(DramareelColors.textPrimary)
                                    .lineLimit(1)
                                
                                // Description synopsis
                                Text(drama.description)
                                    .font(DramareelTypography.body(size: 12))
                                    .foregroundColor(DramareelColors.textSecondary)
                                    .lineLimit(2)
                                
                                // Action Buttons
                                HStack(spacing: 12) {
                                    // Play Episode 1
                                    Button(action: { onPlayDrama(drama) }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "play.fill")
                                                .font(.system(size: 14, weight: .bold))
                                            Text("Play Episode 1")
                                                .font(DramareelTypography.button(size: 14))
                                        }
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 18)
                                        .padding(.vertical, 10)
                                        .background(DramareelColors.actionGradient)
                                        .cornerRadius(10)
                                        .shadow(color: DramareelColors.neonPink.opacity(0.4), radius: 8, x: 0, y: 3)
                                    }
                                    
                                    // Details Button
                                    Button(action: { onSelectDrama(drama) }) {
                                        HStack(spacing: 5) {
                                            Image(systemName: "info.circle")
                                                .font(.system(size: 14))
                                            Text("Details")
                                                .font(DramareelTypography.button(size: 14))
                                        }
                                        .foregroundColor(DramareelColors.textPrimary)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 10)
                                        .background(DramareelColors.surfaceGlass.opacity(0.8))
                                        .cornerRadius(10)
                                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(DramareelColors.surfaceBorder, lineWidth: 1))
                                    }
                                }
                                .padding(.top, 4)
                            }
                            .padding(.horizontal, 18)
                            .padding(.bottom, 16)
                        }
                        .tag(index)
                    }
                }
                .frame(height: 380)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .onReceive(timer) { _ in
                    guard !dramas.isEmpty else { return }
                    withAnimation {
                        currentIndex = (currentIndex + 1) % dramas.count
                    }
                }
                
                // Pagination Dots
                HStack(spacing: 6) {
                    ForEach(0..<dramas.count, id: \.self) { i in
                        Capsule()
                            .fill(i == currentIndex ? DramareelColors.neonPink : DramareelColors.surfaceBorder)
                            .frame(width: i == currentIndex ? 16 : 6, height: 4)
                            .animation(.spring(), value: currentIndex)
                    }
                }
                .padding(.top, 2)
            }
        )
    }
}
