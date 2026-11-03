import Foundation
import SwiftUI
import Combine

@MainActor
public final class ShortsViewModel: ObservableObject {
    @Published public var shorts: [ShortItem] = []
    @Published public var currentIndex: Int = 0
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil
    @Published public var isMuted: Bool = false
    @Published public var likedDramaIds: Set<String> = []
    
    private let apiClient: APIClient
    private let localStorage: LocalStorageManager
    private let authService: AuthService
    
    public init(
        apiClient: APIClient = .shared,
        localStorage: LocalStorageManager = .shared,
        authService: AuthService = .shared
    ) {
        self.apiClient = apiClient
        self.localStorage = localStorage
        self.authService = authService
    }
    
    public func loadShorts() async {
        guard shorts.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        
        do {
            let lang = UserDefaults.standard.string(forKey: AppConstants.StorageKeys.selectedLanguageCode) ?? "en"
            let items: [ShortItem] = try await apiClient.request(.shorts(lang: lang))
            self.shorts = items
            self.isLoading = false
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }
    
    public func toggleLike(dramaId: String) async {
        guard let uid = authService.currentUser?.uid else { return }
        
        if likedDramaIds.contains(dramaId) {
            likedDramaIds.remove(dramaId)
        } else {
            likedDramaIds.insert(dramaId)
        }
        
        let body: [String: Any] = [
            "action": "toggleLike",
            "seriesId": dramaId
        ]
        
        _ = try? await apiClient.requestRaw(.postLibrary(uid: uid, body: body))
    }
}
