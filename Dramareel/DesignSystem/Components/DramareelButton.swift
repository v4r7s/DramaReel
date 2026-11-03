import SwiftUI

public enum DramareelButtonStyle {
    case primaryGradient
    case secondaryGlass
    case coinGold
    case destructive
}

public struct DramareelButton: View {
    public let title: String
    public var icon: String? = nil
    public var style: DramareelButtonStyle = .primaryGradient
    public var isLoading: Bool = false
    public var isFullWidth: Bool = true
    public let action: () -> Void
    
    public init(
        title: String,
        icon: String? = nil,
        style: DramareelButtonStyle = .primaryGradient,
        isLoading: Bool = false,
        isFullWidth: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.isLoading = isLoading
        self.isFullWidth = isFullWidth
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            guard !isLoading else { return }
            action()
        }) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .bold))
                    }
                    Text(title)
                        .font(DramareelTypography.button(size: 15))
                }
            }
            .foregroundColor(.white)
            .padding(.vertical, 14)
            .padding(.horizontal, isFullWidth ? 16 : 24)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .background(backgroundView)
            .cornerRadius(14)
            .overlay(borderOverlay)
            .shadow(color: shadowColor, radius: 8, x: 0, y: 3)
        }
        .disabled(isLoading)
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .primaryGradient:
            DramareelColors.actionGradient
        case .secondaryGlass:
            DramareelColors.surfaceGlass.opacity(0.8)
        case .coinGold:
            DramareelColors.coinGoldGradient
        case .destructive:
            DramareelColors.errorRed.opacity(0.85)
        }
    }
    
    @ViewBuilder
    private var borderOverlay: some View {
        switch style {
        case .primaryGradient:
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        case .secondaryGlass:
            RoundedRectangle(cornerRadius: 14)
                .stroke(DramareelColors.surfaceBorder, lineWidth: 1)
        case .coinGold:
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        case .destructive:
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        }
    }
    
    private var shadowColor: Color {
        switch style {
        case .primaryGradient:
            return DramareelColors.neonPink.opacity(0.35)
        case .secondaryGlass:
            return Color.clear
        case .coinGold:
            return DramareelColors.coinGold.opacity(0.35)
        case .destructive:
            return DramareelColors.errorRed.opacity(0.3)
        }
    }
}
