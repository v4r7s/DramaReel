import Foundation

public final class APIClient: @unchecked Sendable {
    public static let shared = APIClient()
    
    private let session: URLSession
    private let decoder: JSONDecoder
    
    public var baseURL: String {
        get {
            var raw = AppConstants.defaultBaseURL
            if let custom = UserDefaults.standard.string(forKey: AppConstants.StorageKeys.customApiBaseURL), !custom.isEmpty {
                raw = custom
            }
            raw = raw.trimmingCharacters(in: CharacterSet(charactersIn: "/ "))
            if raw.hasSuffix("/api/mobile/v1") {
                raw = String(raw.dropLast("/api/mobile/v1".count))
            } else if raw.hasSuffix("/api") {
                raw = String(raw.dropLast("/api".count))
            }
            return raw.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        }
        set {
            UserDefaults.standard.set(newValue, forKey: AppConstants.StorageKeys.customApiBaseURL)
        }
    }
    
    public var apiKey: String {
        get {
            if let custom = UserDefaults.standard.string(forKey: AppConstants.StorageKeys.customApiKey), !custom.isEmpty {
                return custom
            }
            return AppConstants.defaultApiKey
        }
        set {
            UserDefaults.standard.set(newValue, forKey: AppConstants.StorageKeys.customApiKey)
        }
    }
    
    public init(session: URLSession = .shared) {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 25
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        self.decoder = decoder
    }
    
    // MARK: - Execute Request
    public func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let data = try await requestRaw(endpoint)
        do {
            return try decoder.decode(T.self, from: data)
        } catch let decodeErr {
            #if DEBUG
            let rawString = String(data: data, encoding: .utf8) ?? "binary"
            print("Decoding failure on \(endpoint.path): \(decodeErr). Raw payload: \(rawString)")
            #endif
            throw NetworkError.decodingError(decodeErr.localizedDescription)
        }
    }
    
    public func requestRaw(_ endpoint: APIEndpoint) async throws -> Data {
        let fullUrlString = "\(baseURL)\(endpoint.path)"
        guard var components = URLComponents(string: fullUrlString) else {
            throw NetworkError.invalidURL
        }
        
        if let queryItems = endpoint.queryItems {
            components.queryItems = queryItems
        }
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body
        
        HTTPInterceptor.applyHeaders(to: &request, apiKey: apiKey)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                return data
            case 401:
                throw NetworkError.unauthorized
            case 403:
                let msg = parseErrorMessage(from: data) ?? "Access denied."
                throw NetworkError.forbidden(msg)
            case 404:
                throw NetworkError.notFound
            case 409:
                let msg = parseErrorMessage(from: data) ?? "Resource conflict."
                throw NetworkError.conflict(msg)
            default:
                let msg = parseErrorMessage(from: data) ?? "Server returned error."
                throw NetworkError.serverError(httpResponse.statusCode, msg)
            }
        } catch let netErr as NetworkError {
            throw netErr
        } catch {
            throw NetworkError.networkFailure(error.localizedDescription)
        }
    }
    
    private func parseErrorMessage(from data: Data) -> String? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return json["error"] as? String ?? json["message"] as? String
    }
}
