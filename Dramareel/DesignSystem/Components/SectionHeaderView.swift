import SwiftUI

public struct ShimmerView: View {
    @State private var phase: CGFloat = -1.0
    
    public init() {}
    
    public var body: some View {
        GeometryReader { geometry in
            RoundedRectangle(cornerRadius: 12)
                .fill(DramareelColors.surfaceCard)
                .overlay(
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color.white.opacity(0.12),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .offset(x: phase * geometry.size.width)
                )
                .clipped()
                .onAppear {
                    withAnimation(
                        .linear(duration: 1.5)
                        .repeatForever(autoreverses: false)
                    ) {
                        phase = 1.0
                    }
                }
        }
    }
}

public struct SectionHeaderView: View {
    public let title: String
    public var icon: String? = nil
    public var showSeeAll: Bool = true
    public var onSeeAll: (() -> Void)? = nil
    
    public init(
        title: String,
        icon: String? = nil,
        showSeeAll: Bool = true,
        onSeeAll: (() -> Void)? = nil
    ) {
        self.title = title
        self.icon = icon
        self.showSeeAll = showSeeAll
        self.onSeeAll = onSeeAll
    }
    
    public var body: some View {
        HStack {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [DramareelColors.neonPink, DramareelColors.electricCyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                Text(title)
                    .font(DramareelTypography.sectionTitle(size: 18))
                    .foregroundColor(DramareelColors.textPrimary)
            }
            
            Spacer()
            
            if showSeeAll {
                Button(action: { onSeeAll?() }) {
                    HStack(spacing: 3) {
                        Text("See All")
                            .font(DramareelTypography.caption(size: 13))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundColor(DramareelColors.textSecondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
}
