import SwiftUI

public struct SplashScreenView: View {
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.0
    @State private var sloganOpacity: Double = 0.0
    
    public init() {}
    
    public var body: some View {
        ZStack {
            DramareelColors.backgroundDark
                .ignoresSafeArea()
            
            // Background cosmic aura
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            DramareelColors.primaryPurple.opacity(0.35),
                            DramareelColors.neonPink.opacity(0.15),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 180
                    )
                )
                .frame(width: 360, height: 360)
                .blur(radius: 50)
            
            VStack(spacing: 20) {
                // 3D Multicolor Logo
                DramareelLogoView(size: 72, showWordmark: true, showSlogan: false)
                    .scaleEffect(scale)
                    .opacity(opacity)
                
                // Slogan
                Text(AppConstants.appSlogan)
                    .font(DramareelTypography.caption(size: 14))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.white, DramareelColors.textSecondary],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .tracking(1.0)
                    .opacity(sloganOpacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.65)) {
                scale = 1.0
                opacity = 1.0
            }
            withAnimation(.easeIn(duration: 0.8).delay(0.5)) {
                sloganOpacity = 1.0
            }
        }
    }
}
