import Foundation

public struct UserProfile: Identifiable, Codable, Sendable {
    public var id: String { uid }
    public let uid: String
    public let email: String?
    public let displayName: String?
    public let photoURL: String?
    public var coins: Int
    public var isVip: Bool
    public var vipExpiry: String?
    public let publicId: String?
    public var todayAdCount: Int
    public var unlockedEpisodeIds: [String]
    public var claimedTaskIds: [String]
    public let referralCode: String?
    public let referralCount: Int
    public let referralEarnings: Int
    public let referredBy: String?
    public var lastCheckInDate: String?
    public var consecutiveCheckInDays: Int
    
    public init(
        uid: String,
        email: String? = nil,
        displayName: String? = nil,
        photoURL: String? = nil,
        coins: Int = 100,
        isVip: Bool = false,
        vipExpiry: String? = nil,
        publicId: String? = nil,
        todayAdCount: Int = 0,
        unlockedEpisodeIds: [String] = [],
        claimedTaskIds: [String] = [],
        referralCode: String? = nil,
        referralCount: Int = 0,
        referralEarnings: Int = 0,
        referredBy: String? = nil,
        lastCheckInDate: String? = nil,
        consecutiveCheckInDays: Int = 0
    ) {
        self.uid = uid
        self.email = email
        self.displayName = displayName
        self.photoURL = photoURL
        self.coins = coins
        self.isVip = isVip
        self.vipExpiry = vipExpiry
        self.publicId = publicId
        self.todayAdCount = todayAdCount
        self.unlockedEpisodeIds = unlockedEpisodeIds
        self.claimedTaskIds = claimedTaskIds
        self.referralCode = referralCode
        self.referralCount = referralCount
        self.referralEarnings = referralEarnings
        self.referredBy = referredBy
        self.lastCheckInDate = lastCheckInDate
        self.consecutiveCheckInDays = consecutiveCheckInDays
    }
    
    public var isVipActive: Bool {
        guard isVip else { return false }
        guard let expiryString = vipExpiry, !expiryString.isEmpty else { return true }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let expiryDate = formatter.date(from: expiryString) {
            return expiryDate > Date()
        }
        let fallback = DateFormatter()
        fallback.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let expiryDate = fallback.date(from: expiryString) {
            return expiryDate > Date()
        }
        return true
    }
}
