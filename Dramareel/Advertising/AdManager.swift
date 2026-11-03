import Foundation
import UIKit
import SwiftUI
import GoogleMobileAds

@MainActor
public final class AdManager: ObservableObject {
    public static let shared = AdManager()
    
    @Published public var isInitialized: Bool = false
    @Published public var settings: AppSettings = .default
    
    private let apiClient: APIClient
    
    private init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }
    
    public func initialize() {
        guard !isInitialized else { return }
        
        GADMobileAds.sharedInstance().start { [weak self] status in
            DispatchQueue.main.async {
                self?.isInitialized = true
                self?.preloadAdsIfConfigured()
            }
        }
        
        Task {
            await loadSettings()
        }
    }
    
    public func loadSettings() async {
        do {
            let appSettings: AppSettings = try await apiClient.request(.settings(platform: "ios"))
            self.settings = appSettings
            preloadAdsIfConfigured()
        } catch {
            #if DEBUG
            print("Failed to load ad settings: \(error.localizedDescription)")
            #endif
        }
    }
    
    private func preloadAdsIfConfigured() {
        let rewardedId = getRewardedAdUnitId()
        AdMobRewardedCoordinator.shared.preloadAd(adUnitId: rewardedId)
    }
    
    public func getRewardedAdUnitId() -> String {
        if settings.admobRewardedEnabled && !settings.admobRewardedId.isEmpty {
            return settings.admobRewardedId
        }
        return AppConstants.AdMobTestIDs.rewarded
    }
    
    public func getBannerAdUnitId() -> String {
        if settings.admobBannerEnabled && !settings.admobBannerId.isEmpty {
            return settings.admobBannerId
        }
        return AppConstants.AdMobTestIDs.banner
    }
    
    // MARK: - Present Rewarded Ad
    public func showRewardedAd(
        from viewController: UIViewController,
        onRewarded: @escaping () -> Void,
        onDismiss: @escaping () -> Void = {},
        onError: @escaping (String) -> Void = { _ in }
    ) {
        let adUnitId = getRewardedAdUnitId()
        AdMobRewardedCoordinator.shared.showAd(
            adUnitId: adUnitId,
            from: viewController,
            onRewarded: onRewarded,
            onDismiss: onDismiss,
            onError: onError
        )
    }
}

// SwiftUI Banner Component
public struct AdMobBannerView: UIViewRepresentable {
    public let adUnitId: String
    
    public init(adUnitId: String) {
        self.adUnitId = adUnitId
    }
    
    public func makeUIView(context: Context) -> GADBannerView {
        let banner = GADBannerView(adSize: GADAdSizeBanner)
        banner.adUnitID = adUnitId
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            banner.rootViewController = rootVC
        }
        banner.load(GADRequest())
        return banner
    }
    
    public func updateUIView(_ uiView: GADBannerView, context: Context) {}
}
