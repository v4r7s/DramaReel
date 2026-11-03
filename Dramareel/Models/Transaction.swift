import Foundation

public struct CoinTransactionItem: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let userId: String?
    public let type: String // "purchase" or "spend"
    public let amount: Int
    public let description: String
    public let createdAt: String
    
    public init(
        id: String,
        userId: String? = nil,
        type: String = "spend",
        amount: Int = 0,
        description: String = "",
        createdAt: String = ""
    ) {
        self.id = id
        self.userId = userId
        self.type = type
        self.amount = amount
        self.description = description
        self.createdAt = createdAt
    }
    
    public var isPositive: Bool {
        amount > 0 || type == "purchase"
    }
}
