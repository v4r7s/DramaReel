import SwiftUI

public enum DramareelColors {
    // MARK: - Dark Premium Streaming Foundation
    /// Deep cosmic background `#07060D`
    public static let backgroundDark = Color(red: 0.03, green: 0.02, blue: 0.05)
    /// Surface card background with subtle violet tint `#120E22`
    public static let surfaceCard = Color(red: 0.07, green: 0.05, blue: 0.13)
    /// Elevated glass surface `#1B1533` with 60% opacity
    public static let surfaceGlass = Color(red: 0.11, green: 0.08, blue: 0.20)
    /// Deep surface border stroke `#2B234D`
    public static let surfaceBorder = Color(red: 0.17, green: 0.14, blue: 0.30)
    
    // MARK: - Dramareel Signature 3D Play Symbol Gradient Colors
    /// Royal Violet `#7B2CBF`
    public static let primaryPurple = Color(red: 0.48, green: 0.17, blue: 0.75)
    /// Vibrant Magenta/Pink `#E01E8A`
    public static let neonPink = Color(red: 0.88, green: 0.12, blue: 0.54)
    /// Vivid Cyan `#00F0FF`
    public static let electricCyan = Color(red: 0.00, green: 0.94, blue: 1.00)
    /// Bright Gold `#FFB703` (for Coins and VIP)
    public static let coinGold = Color(red: 1.00, green: 0.72, blue: 0.01)
    /// Rich Amber Gold `#FB8500`
    public static let goldAmber = Color(red: 0.98, green: 0.52, blue: 0.00)
    /// Accent Rose `#F72585`
    public static let accentRose = Color(red: 0.97, green: 0.15, blue: 0.52)
    
    // MARK: - Typography & Feedback Colors
    public static let textPrimary = Color.white
    public static let textSecondary = Color(white: 0.75)
    public static let textMuted = Color(white: 0.48)
    public static let errorRed = Color(red: 0.95, green: 0.20, blue: 0.25)
    public static let successGreen = Color(red: 0.15, green: 0.82, blue: 0.45)
    
    // MARK: - Signature Gradients
    /// The iconic Dramareel 3D Multicolor Gradient (Purple -> Magenta -> Pink -> Cyan)
    public static let dramareelHeroGradient = LinearGradient(
        colors: [primaryPurple, neonPink, electricCyan],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Vibrant Purple/Pink action gradient for Primary CTA buttons
    public static let actionGradient = LinearGradient(
        colors: [Color(red: 0.56, green: 0.15, blue: 0.90), neonPink],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    /// Coin & VIP Gold Gradient
    public static let coinGoldGradient = LinearGradient(
        colors: [coinGold, goldAmber],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Cinematic Poster Bottom Shadow Scrim
    public static let posterScrim = LinearGradient(
        colors: [Color.clear, backgroundDark.opacity(0.8), backgroundDark],
        startPoint: .top,
        endPoint: .bottom
    )
    
    /// Glass Shimmer Highlight Gradient
    public static let glassShimmer = LinearGradient(
        colors: [Color.white.opacity(0.0), Color.white.opacity(0.12), Color.white.opacity(0.0)],
        startPoint: .leading,
        endPoint: .trailing
    )
}
