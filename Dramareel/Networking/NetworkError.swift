import Foundation

public enum NetworkError: LocalizedError, Sendable {
    case invalidURL
    case unauthorized
    case forbidden(String)
    case notFound
    case conflict(String)
    case serverError(Int, String)
    case decodingError(String)
    case networkFailure(String)
    case unknown
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid request URL."
        case .unauthorized:
            return "Session expired or unauthorized. Please sign in again."
        case .forbidden(let msg):
            return msg.isEmpty ? "Access denied." : msg
        case .notFound:
            return "Requested content not found."
        case .conflict(let msg):
            return msg.isEmpty ? "Action conflict." : msg
        case .serverError(let code, let msg):
            return "Server error (\(code)): \(msg)"
        case .decodingError(let msg):
            return "Data parsing error: \(msg)"
        case .networkFailure(let msg):
            return "Network connection issue: \(msg)"
        case .unknown:
            return "An unexpected error occurred. Please try again."
        }
    }
}
