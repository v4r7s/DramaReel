import Foundation

public struct SubtitleTrack: Identifiable, Codable, Hashable, Sendable {
    public var id: String { languageCode }
    public let language: String
    public let languageCode: String
    public let url: String
    
    public init(language: String, languageCode: String, url: String) {
        self.language = language
        self.languageCode = languageCode
        self.url = url
    }
}

public struct Episode: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let dramaId: String
    public let title: String
    public let episodeNumber: Int
    public let videoUrl: String
    public let isPremium: Bool
    public let coinCost: Int
    public let durationSec: Int
    public let subtitles: [SubtitleTrack]
    
    public init(
        id: String,
        dramaId: String,
        title: String = "Episode",
        episodeNumber: Int = 1,
        videoUrl: String = "",
        isPremium: Bool = false,
        coinCost: Int = 0,
        durationSec: Int = 0,
        subtitles: [SubtitleTrack] = []
    ) {
        self.id = id
        self.dramaId = dramaId
        self.title = title
        self.episodeNumber = episodeNumber
        self.videoUrl = videoUrl
        self.isPremium = isPremium
        self.coinCost = coinCost
        self.durationSec = durationSec
        self.subtitles = subtitles
    }
}

public struct ShortItem: Identifiable, Codable, Hashable, Sendable {
    public var id: String { episode.id }
    public let drama: Drama
    public let episode: Episode
    
    public init(drama: Drama, episode: Episode) {
        self.drama = drama
        self.episode = episode
    }
}
