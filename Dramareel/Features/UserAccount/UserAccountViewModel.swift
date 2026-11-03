import Foundation
import SwiftUI

public struct WatchHistoryItem: Identifiable, Codable, Hashable, Sendable {
    public var id: String { "\(seriesId)_\(episodeId)" }
    public let seriesId: String
    public let episodeId: String
    public let episodeInSeason: Int
    public let progress: Int
    public let watchedAt: String
}

public struct FavoriteItem: Identifiable, Codable, Hashable, Sendable {
    public var id: String { seriesId }
    public let seriesId: String
}

@MainActor
public final class UserAccountViewModel: ObservableObject {
    @Published public var historyItems: [WatchHistoryItem] = []
    @Published public var favoriteDramas: [Drama] = []
    @Published public var transactions: [CoinTransactionItem] = []
    @Published public var isLoading: Bool = false
    @Published public var isDeletingAccount: Bool = false
    @Published public var errorMessage: String? = nil
    
    private let apiClient: APIClient
    private let authService: AuthService
    
    public init(apiClient: APIClient = .shared, authService: AuthService = .shared) {
        self.apiClient = apiClient
        self.authService = authService
    }
    
    public func loadUserData(allDramas: [Drama]) async {
        guard let uid = authService.currentUser?.uid else { return }
        isLoading = true
        
        async let fetchLibraryTask = fetchLibrary(uid: uid, allDramas: allDramas)
        async let fetchTransactionsTask = fetchTransactions(uid: uid)
        
        _ = await (fetchLibraryTask, fetchTransactionsTask)
        isLoading = false
    }
    
    private func fetchLibrary(uid: String, allDramas: [Drama]) async {
        do {
            let data = try await apiClient.requestRaw(.getLibrary(uid: uid))
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                // Parse history
                if let historyArray = json["history"] as? [[String: Any]] {
                    self.historyItems = historyArray.compactMap { dict in
                        guard let sId = dict["seriesId"] as? String,
                              let eId = dict["episodeId"] as? String else { return nil }
                        let epNum = dict["episodeInSeason"] as? Int ?? 1
                        let prog = dict["progress"] as? Int ?? 0
                        let watched = dict["watchedAt"] as? String ?? ""
                        return WatchHistoryItem(seriesId: sId, episodeId: eId, episodeInSeason: epNum, progress: prog, watchedAt: watched)
                    }
                }
                
                // Parse favorites
                if let favsArray = json["favorites"] as? [[String: Any]] {
                    let favIds = Set(favsArray.compactMap { $0["seriesId"] as? String })
                    self.favoriteDramas = allDramas.filter { favIds.contains($0.id) }
                }
            }
        } catch {
            #if DEBUG
            print("Failed to load user library: \(error)")
            #endif
        }
    }
    
    private func fetchTransactions(uid: String) async {
        do {
            let list: [CoinTransactionItem] = try await apiClient.request(.getTransactions(uid: uid, limit: 50))
            self.transactions = list
        } catch {
            #if DEBUG
            print("Failed to load transactions: \(error)")
            #endif
        }
    }
    
    public func clearWatchHistory() async {
        guard let uid = authService.currentUser?.uid else { return }
        
        do {
            let body: [String: Any] = ["action": "clearHistory"]
            _ = try await apiClient.requestRaw(.postLibrary(uid: uid, body: body))
            self.historyItems = []
        } catch {
            #if DEBUG
            print("Failed to clear history: \(error)")
            #endif
        }
    }
}
