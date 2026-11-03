import Foundation
import SwiftUI
import Combine

@MainActor
public final class VideoPlayerViewModel: ObservableObject {
    public let drama: Drama
    @Published public var episodes: [Episode]
    @Published public var currentEpisode: Episode
    @Published public var isControlsVisible: Bool = true
    @Published public var isLandscape: Bool = false
    @Published public var isShowingSubtitleSheet: Bool = false
    @Published public var isShowingEpisodesSheet: Bool = false
    @Published public var watermarkSettings: (enabled: Bool, url: String, position: String, opacity: Double) = (false, "", "top-right", 0.8)
    @Published public var showUnlockModalForNext: Episode? = nil
    
    public let playerEngine = DramareelPlayerEngine()
    private let apiClient: APIClient
    private let localStorage: LocalStorageManager
    private let authService: AuthService
    private var controlsTimer: Timer?
    private var progressSyncTask: Task<Void, Never>?
    
    public init(
        drama: Drama,
        episodes: [Episode],
        initialEpisode: Episode,
        apiClient: APIClient = .shared,
        localStorage: LocalStorageManager = .shared,
        authService: AuthService = .shared
    ) {
        self.drama = drama
        self.episodes = episodes
        self.currentEpisode = initialEpisode
        self.apiClient = apiClient
        self.localStorage = localStorage
        self.authService = authService
        
        setupPlaybackCallbacks()
        loadWatermarkSettings()
        startPlayingCurrentEpisode()
    }
    
    private func setupPlaybackCallbacks() {
        playerEngine.onPlaybackEnded = { [weak self] in
            Task { @MainActor [weak self] in
                self?.handlePlaybackCompleted()
            }
        }
    }
    
    // MARK: - Play Current Episode
    public func startPlayingCurrentEpisode() {
        // Look up previous progress
        var startTime: Double = 0
        if let saved = localStorage.getPlaybackPosition(seriesId: drama.id), saved.episodeId == currentEpisode.id {
            startTime = saved.seconds
        }
        
        playerEngine.loadVideo(urlString: currentEpisode.videoUrl, startTime: startTime)
        startControlsDismissTimer()
        startPeriodicProgressSync()
    }
    
    // MARK: - Switch Episode
    public func selectEpisode(_ episode: Episode) {
        guard episode.id != currentEpisode.id else { return }
        saveCurrentProgress()
        currentEpisode = episode
        startPlayingCurrentEpisode()
    }
    
    // MARK: - Play Next Episode
    public func playNextEpisode() {
        guard let currentIndex = episodes.firstIndex(where: { $0.id == currentEpisode.id }),
              currentIndex + 1 < episodes.count else {
            return
        }
        
        let next = episodes[currentIndex + 1]
        // Check if unlocked
        let isUnlocked = !next.isPremium ||
            authService.currentUser?.isVipActive == true ||
            localStorage.getUnlockedEpisodeIds().contains(next.id)
        
        if isUnlocked {
            selectEpisode(next)
        } else {
            showUnlockModalForNext = next
        }
    }
    
    private func handlePlaybackCompleted() {
        saveCurrentProgress(completed: true)
        playNextEpisode()
    }
    
    // MARK: - Save Progress
    public func saveCurrentProgress(completed: Bool = false) {
        let currentTime = completed ? 0 : playerEngine.currentTime
        localStorage.savePlaybackPosition(
            seriesId: drama.id,
            episodeId: currentEpisode.id,
            episodeNumber: currentEpisode.episodeNumber,
            seconds: currentTime
        )
        
        // Sync to backend if user is logged in
        guard let uid = authService.currentUser?.uid else { return }
        
        Task {
            let body: [String: Any] = [
                "action": "updateHistory",
                "seriesId": drama.id,
                "episodeId": currentEpisode.id,
                "episodeInSeason": currentEpisode.episodeNumber,
                "progress": Int(currentTime)
            ]
            _ = try? await apiClient.requestRaw(.postLibrary(uid: uid, body: body))
        }
    }
    
    private func startPeriodicProgressSync() {
        progressSyncTask?.cancel()
        progressSyncTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 15_000_000_000) // Every 15 sec
                guard let self = self else { break }
                if self.playerEngine.isPlaying {
                    self.saveCurrentProgress()
                }
            }
        }
    }
    
    // MARK: - Controls Visibility
    public func toggleControls() {
        withAnimation {
            isControlsVisible.toggle()
        }
        if isControlsVisible {
            startControlsDismissTimer()
        }
    }
    
    private func startControlsDismissTimer() {
        controlsTimer?.invalidate()
        controlsTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in
                withAnimation {
                    self?.isControlsVisible = false
                }
            }
        }
    }
    
    // MARK: - Watermark
    private func loadWatermarkSettings() {
        Task {
            do {
                let settings: AppSettings = try await apiClient.request(.settings(platform: "ios"))
                self.watermarkSettings = (
                    settings.watermarkEnabled,
                    settings.watermarkUrl,
                    settings.watermarkPosition,
                    settings.watermarkOpacity
                )
            } catch {
                #if DEBUG
                print("Could not load watermark settings: \(error)")
                #endif
            }
        }
    }
    
    deinit {
        controlsTimer?.invalidate()
        progressSyncTask?.cancel()
    }
}
