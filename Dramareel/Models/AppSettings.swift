import Foundation

public struct CoinPack: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let description: String
    public let amount: Int
    public let price: Double
    public let type: String // "coins" or "membership"
    public let appleProductId: String
    public let googleProductId: String?
    
    public init(
        id: String,
        name: String,
        description: String = "",
        amount: Int = 100,
        price: Double = 0.99,
        type: String = "coins",
        appleProductId: String = "",
        googleProductId: String? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.amount = amount
        self.price = price
        self.type = type
        self.appleProductId = appleProductId
        self.googleProductId = googleProductId
    }
}

public struct RewardTask: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let type: String // "link" or "ad"
    public let coins: Int
    public let url: String
    public let timerSeconds: Int
    public let frequency: String // "daily" or "once"
    
    public init(
        id: String,
        title: String,
        type: String = "link",
        coins: Int = 10,
        url: String = "",
        timerSeconds: Int = 15,
        frequency: String = "daily"
    ) {
        self.id = id
        self.title = title
        self.type = type
        self.coins = coins
        self.url = url
        self.timerSeconds = timerSeconds
        self.frequency = frequency
    }
}

public struct LanguageModel: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let languageCode: String
    public let countryCode: String
}

public struct AppSettings: Codable, Sendable {
    public let siteUrl: String
    public let platform: String?
    public let oneSignalAppId: String?
    public let emailLoginEnabled: Bool
    public let googleLoginEnabled: Bool
    public let appleLoginEnabled: Bool
    public let currency: String
    public let currencySymbol: String
    public let coinPacks: [CoinPack]
    public let rewardsEnabled: Bool
    public let dailyRewards: [Int]
    public let rewardTasks: [RewardTask]
    public let referralEnabled: Bool
    public let referralRewardCoins: Int
    public let referredBonusCoins: Int
    public let privacyPolicyUrl: String
    public let termsOfServiceUrl: String
    public let updateUrl: String
    public let versionCode: Int
    public let iosMinVersion: String?
    public let iosBundleId: String?
    public let forceUpdateEnabled: Bool
    public let forceLoginEnabled: Bool
    public let languages: [LanguageModel]?
    public let adsProvider: String
    public let admobAppId: String?
    public let admobBannerId: String
    public let admobBannerEnabled: Bool
    public let admobInterstitialId: String
    public let admobInterstitialEnabled: Bool
    public let admobRewardedId: String
    public let admobRewardedEnabled: Bool
    public let admobRewardedLimit: Int
    public let admobAppOpenId: String
    public let admobAppOpenEnabled: Bool
    public let watermarkEnabled: Bool
    public let watermarkUrl: String
    public let watermarkPosition: String
    public let watermarkOpacity: Double
    
    public static var `default`: AppSettings {
        AppSettings(
            siteUrl: AppConstants.defaultBaseURL,
            platform: "ios",
            oneSignalAppId: nil,
            emailLoginEnabled: true,
            googleLoginEnabled: true,
            appleLoginEnabled: true,
            currency: "USD",
            currencySymbol: "$",
            coinPacks: [],
            rewardsEnabled: true,
            dailyRewards: [10, 15, 20, 25, 30, 40, 50],
            rewardTasks: [],
            referralEnabled: true,
            referralRewardCoins: 50,
            referredBonusCoins: 30,
            privacyPolicyUrl: "",
            termsOfServiceUrl: "",
            updateUrl: "",
            versionCode: 1,
            iosMinVersion: "1.0.0",
            iosBundleId: "com.dramareel.app",
            forceUpdateEnabled: false,
            forceLoginEnabled: false,
            languages: [],
            adsProvider: "admob",
            admobAppId: AppConstants.AdMobTestIDs.appId,
            admobBannerId: AppConstants.AdMobTestIDs.banner,
            admobBannerEnabled: false,
            admobInterstitialId: AppConstants.AdMobTestIDs.interstitial,
            admobInterstitialEnabled: false,
            admobRewardedId: AppConstants.AdMobTestIDs.rewarded,
            admobRewardedEnabled: false,
            admobRewardedLimit: 5,
            admobAppOpenId: AppConstants.AdMobTestIDs.appOpen,
            admobAppOpenEnabled: false,
            watermarkEnabled: false,
            watermarkUrl: "",
            watermarkPosition: "top-right",
            watermarkOpacity: 0.8
        )
    }
}
