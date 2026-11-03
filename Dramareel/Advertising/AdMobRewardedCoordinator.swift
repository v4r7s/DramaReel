import Foundation
import UIKit
import GoogleMobileAds

public final class AdMobRewardedCoordinator: NSObject, GADFullScreenContentDelegate, @unchecked Sendable {
    public static let shared = AdMobRewardedCoordinator()
    
    private var rewardedAd: GADRewardedAd?
    private var isLoading: Bool = false
    private var onRewarded: (() -> Void)?
    private var onDismiss: (() -> Void)?
    private var onError: ((String) -> Void)?
    
    public func preloadAd(adUnitId: String) {
        guard rewardedAd == nil, !isLoading else { return }
        isLoading = true
        
        let request = GADRequest()
        GADRewardedAd.load(withAdUnitID: adUnitId, request: request) { [weak self] ad, error in
            guard let self = self else { return }
            self.isLoading = false
            if let error = error {
                #if DEBUG
                print("Failed to load rewarded ad: \(error.localizedDescription)")
                #endif
                self.rewardedAd = nil
            } else {
                self.rewardedAd = ad
                self.rewardedAd?.fullScreenContentDelegate = self
            }
        }
    }
    
    public func showAd(
        adUnitId: String,
        from viewController: UIViewController,
        onRewarded: @escaping () -> Void,
        onDismiss: @escaping () -> Void,
        onError: @escaping (String) -> Void
    ) {
        self.onRewarded = onRewarded
        self.onDismiss = onDismiss
        self.onError = onError
        
        if let ad = rewardedAd {
            ad.present(fromRootViewController: viewController) { [weak self] in
                self?.onRewarded?()
            }
            rewardedAd = nil
            // Preload next
            preloadAd(adUnitId: adUnitId)
        } else {
            // Load and show directly
            let request = GADRequest()
            GADRewardedAd.load(withAdUnitID: adUnitId, request: request) { [weak self] ad, error in
                guard let self = self else { return }
                if let error = error {
                    onError(error.localizedDescription)
                } else if let ad = ad {
                    ad.fullScreenContentDelegate = self
                    ad.present(fromRootViewController: viewController) { [weak self] in
                        self?.onRewarded?()
                    }
                } else {
                    onError("Failed to display ad.")
                }
            }
        }
    }
    
    // MARK: - GADFullScreenContentDelegate
    public func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        onDismiss?()
    }
    
    public func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        onError?(error.localizedDescription)
    }
}
