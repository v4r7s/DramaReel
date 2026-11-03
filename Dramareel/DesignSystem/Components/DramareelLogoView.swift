import SwiftUI

public struct DramareelLogoView: View {
    public var size: CGFloat = 44
    public var showWordmark: Bool = true
    public var showSlogan: Bool = false
    
    public init(size: CGFloat = 44, showWordmark: Bool = true, showSlogan: Bool = false) {
        self.size = size
        self.showWordmark = showWordmark
        self.showSlogan = showSlogan
    }
    
    public var body: some View {
        HStack(spacing: size * 0.28) {
            // 3D Multicolor Play Symbol
            ZStack {
                // Background depth shadow
                Circle()
                    .fill(DramareelColors.surfaceCard)
                    .frame(width: size, height: size)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [DramareelColors.neonPink, DramareelColors.electricCyan],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: size * 0.05
                            )
                    )
                    .shadow(color: DramareelColors.primaryPurple.opacity(0.6), radius: size * 0.2, x: 0, y: size * 0.05)
                
                // 3D Geometric Play Triangle
                PlayTriangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                DramareelColors.primaryPurple,
                                DramareelColors.neonPink,
                                DramareelColors.electricCyan
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size * 0.44, height: size * 0.48)
                    .offset(x: size * 0.04)
                    .shadow(color: DramareelColors.neonPink.opacity(0.8), radius: size * 0.15, x: 0, y: 0)
            }
            
            if showWordmark {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 0) {
                        Text("DRAMA")
                            .font(.system(size: size * 0.48, weight: .black, design: .rounded))
                            .foregroundStyle(Color.white)
                        Text("REEL")
                            .font(.system(size: size * 0.48, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [DramareelColors.neonPink, DramareelColors.electricCyan],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                    
                    if showSlogan {
                        Text(AppConstants.appSlogan)
                            .font(.system(size: size * 0.22, weight: .semibold, design: .default))
                            .foregroundStyle(DramareelColors.textSecondary)
                            .tracking(0.5)
                    }
                }
            }
        }
    }
}

// Shape for 3D Play Triangle
struct PlayTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
