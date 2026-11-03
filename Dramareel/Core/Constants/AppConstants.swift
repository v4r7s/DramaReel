import Foundation

public enum AppConstants {
    // MARK: - Brand Information
    public static let appName = "Dramareel"
    public static let appSlogan = "Every Story. One More Episode."
    public static let bundleId = "com.dramareel.app"
    public static let appScheme = "dramareel://"
    public static let legacyAppScheme = "snapreels://"
    
    // MARK: - API Configuration (Shared across Android APK & iOS IPA)
    // Note: Can be overridden at runtime via AppEnvironment or Settings
    public static let defaultBaseURL = "https://dramareel.org"
    public static let mobileApiPrefix = "/api/mobile/v1"
    public static let userApiPrefix = "/api/user"
    public static let defaultApiKey = "secret_0f5"
    
    // MARK: - AdMob Test Unit IDs (Official Google AdMob iOS Test IDs)
    public enum AdMobTestIDs {
        public static let appId = "ca-app-pub-3940256099942544~1458002511"
        public static let banner = "ca-app-pub-3940256099942544/2934735716"
        public static let interstitial = "ca-app-pub-3940256099942544/4411468910"
        public static let rewarded = "ca-app-pub-3940256099942544/1712485313"
        public static let appOpen = "ca-app-pub-3940256099942544/5662645252"
    }
    
    // MARK: - Storage Keys
    public enum StorageKeys {
        public static let authToken = "dramareel_auth_token"
        public static let currentUserEmail = "dramareel_user_email"
        public static let currentUserId = "dramareel_user_id"
        public static let customApiBaseURL = "dramareel_custom_api_url"
        public static let customApiKey = "dramareel_custom_api_key"
        public static let selectedLanguageCode = "dramareel_selected_language"
        public static let autoUnlockEnabled = "dramareel_auto_unlock_enabled"
        public static let hasCompletedOnboarding = "dramareel_has_completed_onboarding"
        public static let cachedDramasPrefix = "cached_dramas_"
        public static let cachedShortsPrefix = "cached_shorts_"
        public static let cachedCategories = "cached_categories"
    }
    
    // MARK: - Keychain Keys
    public enum KeychainKeys {
        public static let serviceName = "com.dramareel.app.auth"
        public static let firebaseIdToken = "firebase_id_token"
        public static let userUid = "current_user_uid"
        public static let userEmail = "current_user_email"
    }
    
    // MARK: - Timing & Pagination
    public static let splashDelaySeconds: Double = 2.0
    public static let shortReelPreloadCount: Int = 3
    public static let defaultRewardCooldownMinutes: Int = 10
}
