import SwiftUI

public struct DramaPosterCard: View {
    public let drama: Drama
    public var width: CGFloat = 135
    public var height: CGFloat = 195
    public let onTap: () -> Void
    
    public init(drama: Drama, width: CGFloat = 135, height: CGFloat = 195, onTap: @escaping () -> Void) {
        self.drama = drama
        self.width = width
        self.height = height
        self.onTap = onTap
    }
    
    public var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 6) {
                // Poster Image Container
                ZStack(alignment: .topTrailing) {
                    // Image with loading & error fallback
                    AsyncImage(url: URL(string: drama.coverUrl)) { phase in
                        switch phase {
                        case .empty:
                            ShimmerView()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            ZStack {
                                DramareelColors.surfaceCard
                                Image(systemName: "film")
                                    .font(.system(size: 30))
                                    .foregroundColor(DramareelColors.textMuted)
                            }
                        @unknown default:
                            DramareelColors.surfaceCard
                        }
                    }
                    .frame(width: width, height: height)
                    .clipped()
                    .cornerRadius(12)
                    
                    // Bottom gradient scrim for episode count
                    VStack {
                        Spacer()
                        HStack {
                            Text("\(drama.totalEpisodes) Episodes")
                                .font(DramareelTypography.tag(size: 9))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color.black.opacity(0.65))
                                .cornerRadius(6)
                            Spacer()
                            
                            // Star rating
                            HStack(spacing: 2) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 8))
                                    .foregroundColor(DramareelColors.coinGold)
                                Text(String(format: "%.1f", drama.rating))
                                    .font(DramareelTypography.tag(size: 9))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 5)
                            .padding(.vertical, 3)
                            .background(Color.black.opacity(0.65))
                            .cornerRadius(6)
                        }
                        .padding(6)
                    }
                    .frame(width: width, height: height)
                    
                    // Top badges (Trending or HD)
                    HStack {
                        if drama.isTrending {
                            Text("TRENDING")
                                .font(DramareelTypography.tag(size: 8))
                                .foregroundColor(.white)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2.5)
                                .background(
                                    LinearGradient(
                                        colors: [DramareelColors.neonPink, DramareelColors.primaryPurple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(4)
                                .padding(6)
                        }
                        Spacer()
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(DramareelColors.surfaceBorder.opacity(0.6), lineWidth: 1)
                )
                
                // Title and Category
                VStack(alignment: .leading, spacing: 2) {
                    Text(drama.title)
                        .font(DramareelTypography.dramaTitle(size: 13))
                        .foregroundColor(DramareelColors.textPrimary)
                        .lineLimit(1)
                    
                    Text(drama.category)
                        .font(DramareelTypography.caption(size: 11))
                        .foregroundColor(DramareelColors.textSecondary)
                        .lineLimit(1)
                }
                .frame(width: width, alignment: .leading)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
