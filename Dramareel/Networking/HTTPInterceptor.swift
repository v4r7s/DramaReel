import Foundation

public struct HTTPInterceptor {
    public static func applyHeaders(to request: inout URLRequest, apiKey: String) {
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        request.setValue("ios", forHTTPHeaderField: "X-Platform")
        request.setValue("Dramareel-iOS/1.0.0 (Apple; iOS)", forHTTPHeaderField: "User-Agent")
        
        // Inject Firebase ID Token if stored in Keychain
        if let token = KeychainManager.shared.get(key: AppConstants.KeychainKeys.firebaseIdToken), !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }
}
