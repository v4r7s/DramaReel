import SwiftUI

public struct LoadingStateView: View {
    public var message: String = "Loading Dramas..."
    
    public init(message: String = "Loading Dramas...") {
        self.message = message
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: DramareelColors.neonPink))
                .scaleEffect(1.3)
            
            Text(message)
                .font(DramareelTypography.caption(size: 13))
                .foregroundColor(DramareelColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

public struct EmptyStateView: View {
    public let icon: String
    public let title: String
    public let message: String
    public var actionTitle: String? = nil
    public var onAction: (() -> Void)? = nil
    
    public init(
        icon: String = "sparkles.tv",
        title: String = "No Dramas Found",
        message: String = "Check back soon for new episodes and releases.",
        actionTitle: String? = nil,
        onAction: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.onAction = onAction
    }
    
    public var body: some View {
        VStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 44))
                .foregroundStyle(
                    LinearGradient(
                        colors: [DramareelColors.neonPink, DramareelColors.electricCyan],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .padding(.bottom, 4)
            
            Text(title)
                .font(DramareelTypography.sectionTitle(size: 18))
                .foregroundColor(DramareelColors.textPrimary)
            
            Text(message)
                .font(DramareelTypography.body(size: 13))
                .foregroundColor(DramareelColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            if let actionTitle = actionTitle, let onAction = onAction {
                DramareelButton(
                    title: actionTitle,
                    style: .primaryGradient,
                    isFullWidth: false,
                    action: onAction
                )
                .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
    }
}

public struct ErrorStateView: View {
    public let title: String
    public let message: String
    public var onRetry: (() -> Void)? = nil
    
    public init(
        title: String = "Connection Error",
        message: String = "Unable to connect to Dramareel server. Please check your internet connection.",
        onRetry: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.onRetry = onRetry
    }
    
    public var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 42))
                .foregroundColor(DramareelColors.errorRed)
            
            Text(title)
                .font(DramareelTypography.sectionTitle(size: 18))
                .foregroundColor(DramareelColors.textPrimary)
            
            Text(message)
                .font(DramareelTypography.body(size: 13))
                .foregroundColor(DramareelColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            if let onRetry = onRetry {
                DramareelButton(
                    title: "Try Again",
                    icon: "arrow.clockwise",
                    style: .primaryGradient,
                    isFullWidth: false,
                    action: onRetry
                )
                .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
    }
}
