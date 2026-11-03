import Foundation

public struct Drama: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let description: String
    public let coverUrl: String
    public let featuredCoverUrl: String?
    public let category: String
    public let genres: [String]
    public let rating: Double
    public let totalEpisodes: Int
    public let releaseYear: Int
    public let isTrending: Bool
    public let tags: [String]
    public let slug: String?
    public let views: Int
    public let likes: Int
    public let createdAtMillis: Int64
    
    public init(
        id: String,
        title: String,
        description: String,
        coverUrl: String,
        featuredCoverUrl: String? = nil,
        category: String = "Drama",
        genres: [String] = [],
        rating: Double = 4.8,
        totalEpisodes: Int = 1,
        releaseYear: Int = 2026,
        isTrending: Bool = false,
        tags: [String] = [],
        slug: String? = nil,
        views: Int = 0,
        likes: Int = 0,
        createdAtMillis: Int64 = 0
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.coverUrl = coverUrl
        self.featuredCoverUrl = featuredCoverUrl
        self.category = category
        self.genres = genres
        self.rating = rating
        self.totalEpisodes = totalEpisodes
        self.releaseYear = releaseYear
        self.isTrending = isTrending
        self.tags = tags
        self.slug = slug
        self.views = views
        self.likes = likes
        self.createdAtMillis = createdAtMillis
    }
    
    public var displayCoverUrl: URL? {
        if let featured = featuredCoverUrl, !featured.isEmpty, let url = URL(string: featured) {
            return url
        }
        return URL(string: coverUrl)
    }
}
