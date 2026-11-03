import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

public enum APIEndpoint {
    case settings(platform: String)
    case series(lang: String?)
    case episodes(seriesId: String)
    case shorts(lang: String?)
    case categories
    case createUser(uid: String, email: String?, displayName: String?, photoURL: String?)
    case getUser(uid: String)
    case deleteUser(uid: String)
    case getLibrary(uid: String)
    case postLibrary(uid: String, body: [String: Any])
    case getTransactions(uid: String, limit: Int)
    case checkIn(uid: String)
    case unlockEpisode(uid: String, seriesId: String, episodeId: String, episodeNumber: Int, method: String, cost: Int)
    case claimReward(uid: String, taskId: String)
    case claimReferral(userId: String, code: String)
    case forgotPassword(email: String)
    case verifyPurchase(userId: String, packId: String, gateway: String, sessionId: String)
    
    public var path: String {
        switch self {
        case .settings:
            return "/api/mobile/v1/settings"
        case .series:
            return "/api/mobile/v1/series"
        case .episodes:
            return "/api/mobile/v1/episodes"
        case .shorts:
            return "/api/mobile/v1/shorts"
        case .categories:
            return "/api/mobile/v1/categories"
        case .createUser:
            return "/api/user/create"
        case .getUser(let uid):
            return "/api/user/\(uid)"
        case .deleteUser(let uid):
            return "/api/user/\(uid)"
        case .getLibrary(let uid):
            return "/api/user/\(uid)/library"
        case .postLibrary(let uid, _):
            return "/api/user/\(uid)/library"
        case .getTransactions(let uid, _):
            return "/api/user/\(uid)/transactions"
        case .checkIn(let uid):
            return "/api/user/\(uid)/checkin"
        case .unlockEpisode(let uid, _, _, _, _, _):
            return "/api/user/\(uid)/unlock"
        case .claimReward(let uid, _):
            return "/api/user/\(uid)/claim"
        case .claimReferral:
            return "/api/mobile/v1/referral/claim"
        case .forgotPassword:
            return "/api/auth/forgot-password"
        case .verifyPurchase:
            return "/api/mobile/v1/verify-purchase"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .settings, .series, .episodes, .shorts, .categories, .getUser, .getLibrary, .getTransactions:
            return .get
        case .createUser, .postLibrary, .checkIn, .unlockEpisode, .claimReward, .claimReferral, .forgotPassword, .verifyPurchase:
            return .post
        case .deleteUser:
            return .delete
        }
    }
    
    public var queryItems: [URLQueryItem]? {
        switch self {
        case .settings(let platform):
            return [URLQueryItem(name: "platform", value: platform)]
        case .series(let lang):
            guard let lang = lang, !lang.isEmpty else { return nil }
            return [URLQueryItem(name: "lang", value: lang)]
        case .episodes(let seriesId):
            return [URLQueryItem(name: "seriesId", value: seriesId)]
        case .shorts(let lang):
            guard let lang = lang, !lang.isEmpty else { return nil }
            return [URLQueryItem(name: "lang", value: lang)]
        case .getTransactions(_, let limit):
            return [URLQueryItem(name: "limit", value: String(limit))]
        default:
            return nil
        }
    }
    
    public var body: Data? {
        switch self {
        case .createUser(let uid, let email, let displayName, let photoURL):
            var dict: [String: Any] = ["uid": uid]
            if let email = email { dict["email"] = email }
            if let displayName = displayName { dict["displayName"] = displayName }
            if let photoURL = photoURL { dict["photoURL"] = photoURL }
            return try? JSONSerialization.data(withJSONObject: dict)
            
        case .postLibrary(_, let bodyDict):
            return try? JSONSerialization.data(withJSONObject: bodyDict)
            
        case .checkIn:
            return "{}".data(using: .utf8)
            
        case .unlockEpisode(_, let seriesId, let episodeId, let episodeNumber, let method, let cost):
            let dict: [String: Any] = [
                "seriesId": seriesId,
                "episodeId": episodeId,
                "episodeNumber": episodeNumber,
                "method": method,
                "cost": cost
            ]
            return try? JSONSerialization.data(withJSONObject: dict)
            
        case .claimReward(_, let taskId):
            let dict: [String: Any] = ["taskId": taskId]
            return try? JSONSerialization.data(withJSONObject: dict)
            
        case .claimReferral(let userId, let code):
            let dict: [String: Any] = ["userId": userId, "referralCode": code]
            return try? JSONSerialization.data(withJSONObject: dict)
            
        case .forgotPassword(let email):
            let dict: [String: Any] = ["email": email]
            return try? JSONSerialization.data(withJSONObject: dict)
            
        case .verifyPurchase(let userId, let packId, let gateway, let sessionId):
            let dict: [String: Any] = [
                "userId": userId,
                "packId": packId,
                "gateway": gateway,
                "sessionId": sessionId
            ]
            return try? JSONSerialization.data(withJSONObject: dict)
            
        default:
            return nil
        }
    }
}
