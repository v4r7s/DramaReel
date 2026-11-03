import XCTest
@testable import DramareelKit

final class ModelDecodingTests: XCTestCase {
    
    func testDramaDecoding() throws {
        let json = """
        {
            "id": "series_101",
            "title": "Billionaire's Secret Heir",
            "description": "A thrilling tale of power and romance.",
            "coverUrl": "https://example.com/cover.jpg",
            "featuredCoverUrl": "https://example.com/featured.jpg",
            "category": "Romance",
            "genres": ["Romance", "Drama", "Revenge"],
            "rating": 4.9,
            "totalEpisodes": 45,
            "releaseYear": 2026,
            "isTrending": true,
            "tags": ["billionaire", "trending"],
            "slug": "billionaires-secret-heir",
            "views": 154200,
            "likes": 32100,
            "createdAtMillis": 1740000000000
        }
        """.data(using: .utf8)!
        
        let drama = try JSONDecoder().decode(Drama.self, from: json)
        XCTAssertEqual(drama.id, "series_101")
        XCTAssertEqual(drama.title, "Billionaire's Secret Heir")
        XCTAssertEqual(drama.totalEpisodes, 45)
        XCTAssertTrue(drama.isTrending)
        XCTAssertEqual(drama.genres.count, 3)
    }
    
    func testEpisodeDecoding() throws {
        let json = """
        {
            "id": "ep_1",
            "dramaId": "series_101",
            "title": "Episode 1: The Encounter",
            "episodeNumber": 1,
            "videoUrl": "https://example.com/api/hls?v=encrypted_token&ext=.m3u8",
            "isPremium": false,
            "coinCost": 0,
            "durationSec": 115,
            "subtitles": [
                {
                    "language": "English",
                    "languageCode": "en",
                    "url": "https://example.com/sub_en.vtt"
                }
            ]
        }
        """.data(using: .utf8)!
        
        let episode = try JSONDecoder().decode(Episode.self, from: json)
        XCTAssertEqual(episode.id, "ep_1")
        XCTAssertEqual(episode.episodeNumber, 1)
        XCTAssertFalse(episode.isPremium)
        XCTAssertEqual(episode.subtitles.count, 1)
        XCTAssertEqual(episode.subtitles.first?.languageCode, "en")
    }
    
    func testAppSettingsDecodingWithIOSFields() throws {
        let json = """
        {
            "siteUrl": "https://dramareel.example.com",
            "platform": "ios",
            "emailLoginEnabled": true,
            "googleLoginEnabled": true,
            "appleLoginEnabled": true,
            "currency": "USD",
            "currencySymbol": "$",
            "coinPacks": [
                {
                    "id": "pack_1",
                    "name": "Starter Bag",
                    "description": "100 Coins",
                    "amount": 100,
                    "price": 0.99,
                    "type": "coins",
                    "appleProductId": "com.dramareel.coins100"
                }
            ],
            "rewardsEnabled": true,
            "dailyRewards": [10, 15, 20, 25, 30, 40, 50],
            "rewardTasks": [],
            "referralEnabled": true,
            "referralRewardCoins": 50,
            "referredBonusCoins": 30,
            "privacyPolicyUrl": "https://example.com/privacy",
            "termsOfServiceUrl": "https://example.com/terms",
            "updateUrl": "https://apps.apple.com/app/id123456789",
            "versionCode": 1,
            "iosMinVersion": "1.0.0",
            "iosBundleId": "com.dramareel.app",
            "forceUpdateEnabled": false,
            "forceLoginEnabled": false,
            "adsProvider": "admob",
            "admobAppId": "ca-app-pub-3940256099942544~1458002511",
            "admobBannerId": "ca-app-pub-3940256099942544/2934735716",
            "admobBannerEnabled": true,
            "admobInterstitialId": "ca-app-pub-3940256099942544/4411468910",
            "admobInterstitialEnabled": true,
            "admobRewardedId": "ca-app-pub-3940256099942544/1712485313",
            "admobRewardedEnabled": true,
            "admobRewardedLimit": 5,
            "admobAppOpenId": "",
            "admobAppOpenEnabled": false,
            "watermarkEnabled": true,
            "watermarkUrl": "https://example.com/watermark.png",
            "watermarkPosition": "top-right",
            "watermarkOpacity": 0.8
        }
        """.data(using: .utf8)!
        
        let settings = try JSONDecoder().decode(AppSettings.self, from: json)
        XCTAssertEqual(settings.platform, "ios")
        XCTAssertEqual(settings.iosBundleId, "com.dramareel.app")
        XCTAssertEqual(settings.coinPacks.first?.appleProductId, "com.dramareel.coins100")
        XCTAssertTrue(settings.admobRewardedEnabled)
        XCTAssertEqual(settings.admobRewardedLimit, 5)
    }
}
