import Foundation
import SwiftUI

@MainActor
public final class HomeViewModel: ObservableObject {
    @Published public var featuredDramas: [Drama] = []
    @Published public var trendingDramas: [Drama] = []
    @Published public var popularDramas: [Drama] = []
    @Published public var recentDramas: [Drama] = []
    @Published public var allDramas: [Drama] = []
    @Published public var categories: [String] = ["All"]
    @Published public var selectedCategory: String = "All"
    @Published public var searchQuery: String = ""
    @Published public var searchResults: [Drama] = []
    @Published public var isSearching: Bool = false
    
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil
    
    private let apiClient: APIClient
    private let localStorage: LocalStorageManager
    
    public init(apiClient: APIClient = .shared, localStorage: LocalStorageManager = .shared) {
        self.apiClient = apiClient
        self.localStorage = localStorage
    }
    
    public func loadHomeData() async {
        isLoading = true
        errorMessage = nil
        
        async let fetchSeriesTask: [Drama] = fetchSeries()
        async let fetchCategoriesTask: [String] = fetchCategories()
        
        do {
            let (dramas, catList) = try await (fetchSeriesTask, fetchCategoriesTask)
            self.allDramas = dramas
            
            // Partition into sections
            self.featuredDramas = dramas.filter { $0.isTrending || $0.featuredCoverUrl != nil }.prefix(5).map { $0 }
            if self.featuredDramas.isEmpty {
                self.featuredDramas = Array(dramas.prefix(3))
            }
            
            self.trendingDramas = dramas.sorted { $0.views > $1.views }
            self.popularDramas = dramas.sorted { $0.likes > $1.likes }
            self.recentDramas = dramas.sorted { $0.createdAtMillis > $1.createdAtMillis }
            
            var cats = ["All"]
            cats.append(contentsOf: catList.filter { $0 != "All" })
            self.categories = cats
            
            self.isLoading = false
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }
    
    private func fetchSeries() async throws -> [Drama] {
        let lang = UserDefaults.standard.string(forKey: AppConstants.StorageKeys.selectedLanguageCode) ?? "en"
        return try await apiClient.request(.series(lang: lang))
    }
    
    private func fetchCategories() async throws -> [String] {
        return try await apiClient.request(.categories)
    }
    
    public var filteredDramasByCategory: [Drama] {
        if selectedCategory == "All" {
            return allDramas
        }
        return allDramas.filter { drama in
            drama.category.localizedCaseInsensitiveContains(selectedCategory) ||
            drama.genres.contains { $0.localizedCaseInsensitiveContains(selectedCategory) }
        }
    }
    
    public func performSearch() {
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        searchResults = allDramas.filter { drama in
            drama.title.localizedCaseInsensitiveContains(query) ||
            drama.description.localizedCaseInsensitiveContains(query) ||
            drama.category.localizedCaseInsensitiveContains(query) ||
            drama.tags.contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }
}
