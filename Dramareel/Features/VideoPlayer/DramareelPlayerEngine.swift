import Foundation
import AVFoundation
import Combine

public final class DramareelPlayerEngine: ObservableObject, @unchecked Sendable {
    @Published public var isPlaying: Bool = false
    @Published public var currentTime: Double = 0
    @Published public var duration: Double = 0
    @Published public var isBuffering: Bool = false
    @Published public var availableSubtitles: [String] = []
    @Published public var selectedSubtitle: String? = nil
    @Published public var playbackError: String? = nil
    
    public private(set) var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var timeObserverToken: Any?
    private var statusObserver: NSKeyValueObservation?
    private var bufferObserver: NSKeyValueObservation?
    private var cancellables = Set<AnyCancellable>()
    
    public var onPlaybackEnded: (() -> Void)?
    
    public init() {
        setupAudioSession()
        setupInterruptionHandling()
    }
    
    deinit {
        cleanup()
    }
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .moviePlayback, options: [.duckOthers])
            try audioSession.setActive(true)
        } catch {
            #if DEBUG
            print("Failed to configure AVAudioSession: \(error)")
            #endif
        }
    }
    
    private func setupInterruptionHandling() {
        NotificationCenter.default.publisher(for: AVAudioSession.interruptionNotification)
            .sink { [weak self] notification in
                guard let self = self,
                      let userInfo = notification.userInfo,
                      let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
                      let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                    return
                }
                
                if type == .began {
                    self.pause()
                } else if type == .ended {
                    if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                        let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                        if options.contains(.shouldResume) {
                            self.play()
                        }
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Load Video
    public func loadVideo(urlString: String, startTime: Double = 0) {
        cleanup()
        playbackError = nil
        isBuffering = true
        
        guard let url = URL(string: urlString) else {
            playbackError = "Invalid video URL."
            isBuffering = false
            return
        }
        
        let asset = AVURLAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        self.playerItem = item
        
        let player = AVPlayer(playerItem: item)
        player.automaticallyWaitsToMinimizeStalling = true
        self.player = player
        
        // Observe status
        statusObserver = item.observe(\.status, options: [.new]) { [weak self] item, _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch item.status {
                case .readyToPlay:
                    self.isBuffering = false
                    self.duration = item.duration.seconds.isFinite ? item.duration.seconds : 0
                    if startTime > 0 && startTime < self.duration {
                        self.seek(to: startTime)
                    }
                    self.loadSubtitles(from: item)
                    self.play()
                case .failed:
                    self.isBuffering = false
                    self.playbackError = item.error?.localizedDescription ?? "Playback failed."
                case .unknown:
                    break
                @unknown default:
                    break
                }
            }
        }
        
        // Observe buffering
        bufferObserver = item.observe(\.isPlaybackLikelyToKeepUp, options: [.new]) { [weak self] item, _ in
            DispatchQueue.main.async {
                self?.isBuffering = !item.isPlaybackLikelyToKeepUp
            }
        }
        
        // Periodic time observer (every 0.5 sec)
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            let sec = time.seconds
            if sec.isFinite {
                self.currentTime = sec
            }
        }
        
        // End notification
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: item)
            .sink { [weak self] _ in
                self?.isPlaying = false
                self?.onPlaybackEnded?()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Subtitles
    private func loadSubtitles(from item: AVPlayerItem) {
        guard let asset = item.asset as? AVURLAsset else { return }
        if let group = asset.mediaSelectionGroup(forMediaCharacteristic: .legible) {
            let options = group.options
            self.availableSubtitles = options.compactMap { $0.displayName }
        }
    }
    
    public func selectSubtitle(named name: String?) {
        guard let item = playerItem,
              let group = item.asset.mediaSelectionGroup(forMediaCharacteristic: .legible) else {
            return
        }
        
        if let name = name, let option = group.options.first(where: { $0.displayName == name }) {
            item.select(option, in: group)
            self.selectedSubtitle = name
        } else {
            item.select(nil, in: group)
            self.selectedSubtitle = nil
        }
    }
    
    // MARK: - Playback Controls
    public func play() {
        player?.play()
        isPlaying = true
    }
    
    public func pause() {
        player?.pause()
        isPlaying = false
    }
    
    public func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    public func seek(to seconds: Double) {
        let time = CMTime(seconds: seconds, preferredTimescale: 600)
        player?.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    public func cleanup() {
        player?.pause()
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
            timeObserverToken = nil
        }
        statusObserver?.invalidate()
        statusObserver = nil
        bufferObserver?.invalidate()
        bufferObserver = nil
        playerItem = nil
        player = nil
        isPlaying = false
        cancellables.removeAll()
    }
}
