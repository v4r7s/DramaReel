import XCTest
@testable import Dramareel

final class APIEndpointTests: XCTestCase {
    
    let baseURL = URL(string: "https://dramareel.app")!
    
    func testSettingsEndpoint() {
        let endpoint = APIEndpoint.settings(platform: "ios")
        let request = endpoint.makeURLRequest(baseURL: baseURL, token: nil, apiKey: "test_key")
        
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.value(forHTTPHeaderField: "X-API-Key"), "test_key")
        XCTAssertEqual(request.value(forHTTPHeaderField: "X-Platform"), "ios")
        
        let url = request.url!
        XCTAssertTrue(url.absoluteString.contains("/api/mobile/v1/settings"))
        XCTAssertTrue(url.absoluteString.contains("platform=ios"))
    }
    
    func testSeriesEndpointPagination() {
        let endpoint = APIEndpoint.series(page: 2, limit: 10, category: "romance", search: "love")
        let request = endpoint.makeURLRequest(baseURL: baseURL, token: "user_jwt", apiKey: "test_key")
        
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer user_jwt")
        
        let components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)!
        let queryItems = Dictionary(uniqueKeysWithValues: components.queryItems!.map { ($0.name, $0.value ?? "") })
        
        XCTAssertEqual(queryItems["page"], "2")
        XCTAssertEqual(queryItems["limit"], "10")
        XCTAssertEqual(queryItems["category"], "romance")
        XCTAssertEqual(queryItems["search"], "love")
    }
    
    func testUnlockEpisodeRequest() {
        let endpoint = APIEndpoint.unlockEpisode(uid: "user_123", seriesId: "series_456", episodeId: "ep_789")
        let request = endpoint.makeURLRequest(baseURL: baseURL, token: "token", apiKey: "key")
        
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertTrue(request.url!.absoluteString.contains("/api/user/user_123/unlock"))
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
        
        guard let body = request.httpBody,
              let json = try? JSONSerialization.jsonObject(with: body) as? [String: Any] else {
            XCTFail("Invalid HTTP Body JSON")
            return
        }
        
        XCTAssertEqual(json["seriesId"] as? String, "series_456")
        XCTAssertEqual(json["episodeId"] as? String, "ep_789")
    }
    
    func testVerifyPurchaseRequest() {
        let payload: [String: Any] = [
            "gateway": "apple",
            "purchaseToken": "sample_jws_signed_transaction",
            "productId": "coins_500",
            "uid": "user_abc"
        ]
        let endpoint = APIEndpoint.verifyPurchase(payload: payload)
        let request = endpoint.makeURLRequest(baseURL: baseURL, token: "token", apiKey: "key")
        
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertTrue(request.url!.absoluteString.contains("/api/mobile/v1/verify-purchase"))
        
        guard let body = request.httpBody,
              let json = try? JSONSerialization.jsonObject(with: body) as? [String: Any] else {
            XCTFail("Invalid Purchase Payload JSON")
            return
        }
        
        XCTAssertEqual(json["gateway"] as? String, "apple")
        XCTAssertEqual(json["productId"] as? String, "coins_500")
        XCTAssertEqual(json["purchaseToken"] as? String, "sample_jws_signed_transaction")
    }
    
    func testCheckInEndpoint() {
        let endpoint = APIEndpoint.dailyCheckIn(uid: "user_999")
        let request = endpoint.makeURLRequest(baseURL: baseURL, token: "token", apiKey: "key")
        
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertTrue(request.url!.absoluteString.contains("/api/user/user_999/checkin"))
    }
}
