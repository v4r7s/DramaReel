import Foundation
import SwiftUI

@MainActor
public final class DramaDetailViewModel: ObservableObject {
    public let drama: Drama
    
    @Published public var episodes: [Episode] = []
    @Published public var isLoading: Bool = false
    @Published public var isFavorite: Bool = false
    @Published public var isLiked: Bool = false
    @Published public var likesCount: Int = 0
    @Published public var errorMessage: String? = nil
    @Published public var selectedEpisodeToUnlock: Episode? = nil
    @Published public var isUnlocking: Bool = false
    
    private let apiClient: APIClient
    private let localStorage: LocalStorageManager
    private let authService: AuthService
    
    public init(
        drama: Drama,
        apiClient: APIClient = .shared,
        localStorage: LocalStorageManager = .shared,
        authService: AuthService = .shared
    ) {
        self.drama = drama
        self.likesCount = drama.likes
        self.apiClient = apiClient
        self.localStorage = localStorage
        self.authService = authService
    }
    
    public func loadEpisodes() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let list: [Episode] = try await apiClient.request(.episodes(seriesId: drama.id))
            self.episodes = list
            self.isLoading = false
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
        
        await syncUserLibraryState()
    }
    
    // MARK: - Library Sync
    public func syncUserLibraryState() async {
        guard let uid = authService.currentUser?.uid else { return }
        
        do {
            let data = try await apiClient.requestRaw(.getLibrary(uid: uid))
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                if let favorites = json["favorites"] as? [[String: Any]] {
                    self.isFavorite = favorites.contains { ($0["seriesId"] as? String) == self.drama.id }
                }
                if let likedIds = json["likedSeriesIds"] as? [String] {
                    self.isLiked = likedIds.contains(self.drama.id)
                }
            }
        } catch {
            #if DEBUG
            print("Failed to sync library state: \(error)")
            #endif
        }
    }
    
    // MARK: - Favorite & Like
    public func toggleFavorite() async {
        guard let uid = authService.currentUser?.uid else { return }
        
        let previous = isFavorite
        isFavorite.toggle()
        
        let body: [String: Any] = [
            "action": "toggleFavorite",
            "seriesId": drama.id
        ]
        
        do {
            _ = try await apiClient.requestRaw(.postLibrary(uid: uid, body: body))
        } catch {
            isFavorite = previous
        }
    }
    
    public func toggleLike() async {
        guard let uid = authService.currentUser?.uid else { return }
        
        let previous = isLiked
        isLiked.toggle()
        likesCount += (isLiked ? 1 : -1)
        
        let body: [String: Any] = [
            "action": "toggleLike",
            "seriesId": drama.id
        ]
        
        do {
            let data = try await apiClient.requestRaw(.postLibrary(uid: uid, body: body))
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let serverLikes = json["likes"] as? Int {
                self.likesCount = serverLikes
            }
        } catch {
            isLiked = previous
            likesCount += (isLiked ? 1 : -1)
        }
    }
    
    // MARK: - Episode Unlock Check
    public func isEpisodeUnlocked(_ episode: Episode) -> Bool {
        // Free episode
        if !episode.isPremium { return true }
        
        // VIP user has unlocked all
        if authService.currentUser?.isVipActive == true { return true }
        
        // Local storage or profile unlocked IDs
        if localStorage.getUnlockedEpisodeIds().contains(episode.id) {
            return true
        }
        
        if let userUnlocked = authService.currentUser?.unlockedEpisodeIds, userUnlocked.contains(episode.id) {
            return true
        }
        
        return false
    }
    
    // MARK: - Unlock with Coins
    public func unlockWithCoins(episode: Episode) async -> (success: Bool, message: String) {
        guard let uid = authService.currentUser?.uid else {
            return (false, "Please sign in to unlock episodes.")
        }
        
        let currentCoins = authService.currentUser?.coins ?? 0
        guard currentCoins >= episode.coinCost else {
            return (false, "Insufficient coin balance. Please top up your wallet.")
        }
        
        isUnlocking = true
        defer { isUnlocking = false }
        
        do {
            let data = try await apiClient.requestRaw(
                .unlockEpisode(
                    uid: uid,
                    seriesId: drama.id,
                    episodeId: episode.id,
                    episodeNumber: episode.episodeNumber,
                    method: "coins",
                    cost: episode.coinCost
                )
            )
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let updatedCoins = json["coins"] as? Int {
                authService.currentUser?.coins = updatedCoins
            } else {
                authService.currentUser?.coins = max(0, currentCoins - episode.coinCost)
            }
            
            localStorage.markEpisodeUnlocked(id: episode.id)
            authService.currentUser?.unlockedEpisodeIds.append(episode.id)
            selectedEpisodeToUnlock = nil
            return (true, "Episode \(episode.episodeNumber) unlocked successfully!")
        } catch {
            return (false, error.localizedDescription)
        }
    }
    
    // MARK: - Unlock with Rewarded Ad
    public func unlockWithAd(episode: Episode) async -> (success: Bool, message: String) {
        guard let uid = authService.currentUser?.uid else {
            return (false, "Please sign in to unlock episodes.")
        }
        
        isUnlocking = true
        defer { isUnlocking = false }
        
        do {
            let data = try await apiClient.requestRaw(
                .unlockEpisode(
                    uid: uid,
                    seriesId: drama.id,
                    episodeId: episode.id,
                    episodeNumber: episode.episodeNumber,
                    method: "ad",
                    cost: 0
                )
            )
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let todayAdCount = json["todayAdCount"] as? Int {
                authService.currentUser?.todayAdCount = todayAdCount
            }
            
            localStorage.markEpisodeUnlocked(id: episode.id)
            authService.currentUser?.unlockedEpisodeIds.append(episode.id)
            selectedEpisodeToUnlock = nil
            return (true, "Episode \(episode.episodeNumber) unlocked with Ad reward!")
        } catch {
            return (false, error.localizedDescription)
        }
    }
}
