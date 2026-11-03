import Foundation

public final class LocalStorageManager: @unchecked Sendable {
    public static let shared = LocalStorageManager()
    private let userDefaults: UserDefaults
    
    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    // MARK: - Watch Progress
    public func savePlaybackPosition(seriesId: String, episodeId: String, episodeNumber: Int, seconds: Double) {
        let key = "progress_\(seriesId)"
        let dict: [String: Any] = [
            "episodeId": episodeId,
            "episodeNumber": episodeNumber,
            "progressSeconds": seconds,
            "timestamp": Date().timeIntervalSince1970
        ]
        userDefaults.set(dict, forKey: key)
    }
    
    public func getPlaybackPosition(seriesId: String) -> (episodeId: String, episodeNumber: Int, seconds: Double)? {
        let key = "progress_\(seriesId)"
        guard let dict = userDefaults.dictionary(forKey: key),
              let epId = dict["episodeId"] as? String,
              let epNum = dict["episodeNumber"] as? Int,
              let sec = dict["progressSeconds"] as? Double else {
            return nil
        }
        return (epId, epNum, sec)
    }
    
    // MARK: - Local Unlocked Episodes Set
    public func getUnlockedEpisodeIds() -> Set<String> {
        let array = userDefaults.stringArray(forKey: "unlocked_episode_ids") ?? []
        return Set(array)
    }
    
    public func markEpisodeUnlocked(id: String) {
        var set = getUnlockedEpisodeIds()
        set.insert(id)
        userDefaults.set(Array(set), forKey: "unlocked_episode_ids")
    }
    
    public func setUnlockedEpisodeIds(_ ids: Set<String>) {
        userDefaults.set(Array(ids), forKey: "unlocked_episode_ids")
    }
    
    // MARK: - Local Claimed Tasks
    public func getClaimedTaskIds() -> Set<String> {
        let array = userDefaults.stringArray(forKey: "claimed_task_ids") ?? []
        return Set(array)
    }
    
    public func markTaskClaimed(taskId: String) {
        var set = getClaimedTaskIds()
        set.insert(taskId)
        userDefaults.set(Array(set), forKey: "claimed_task_ids")
    }
    
    // MARK: - Cache Catalog Strings
    public func cacheString(key: String, value: String) {
        userDefaults.set(value, forKey: key)
    }
    
    public func getCachedString(key: String) -> String? {
        userDefaults.string(forKey: key)
    }
    
    // MARK: - Auto-unlock Setting
    public var isAutoUnlockEnabled: Bool {
        get { userDefaults.bool(forKey: AppConstants.StorageKeys.autoUnlockEnabled) }
        set { userDefaults.set(newValue, forKey: AppConstants.StorageKeys.autoUnlockEnabled) }
    }
    
    // MARK: - Clear On Logout
    public func clearUserData() {
        userDefaults.removeObject(forKey: "unlocked_episode_ids")
        userDefaults.removeObject(forKey: "claimed_task_ids")
        userDefaults.removeObject(forKey: AppConstants.StorageKeys.currentUserId)
        userDefaults.removeObject(forKey: AppConstants.StorageKeys.currentUserEmail)
    }
}
