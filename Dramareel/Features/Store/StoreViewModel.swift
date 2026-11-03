import Foundation
import SwiftUI
import StoreKit

@MainActor
public final class StoreViewModel: ObservableObject {
    @Published public var coinPacks: [CoinPack] = []
    @Published public var membershipPacks: [CoinPack] = []
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil
    @Published public var successMessage: String? = nil
    
    public let storeKitManager = StoreKitManager.shared
    private let apiClient: APIClient
    
    public init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }
    
    public func loadPacks() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let settings: AppSettings = try await apiClient.request(.settings(platform: "ios"))
            let packs = settings.coinPacks
            
            self.coinPacks = packs.filter { $0.type == "coins" }
            self.membershipPacks = packs.filter { $0.type == "membership" }
            
            // Collect Apple product IDs to fetch from StoreKit
            let productIDs = packs.compactMap { pack in
                pack.appleProductId.isEmpty ? nil : pack.appleProductId
            }
            
            if !productIDs.isEmpty {
                await storeKitManager.fetchProducts(productIdentifiers: productIDs)
            }
            
            self.isLoading = false
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }
    
    public func purchasePack(_ pack: CoinPack) async {
        guard let product = storeKitManager.products.first(where: { $0.id == pack.appleProductId }) else {
            errorMessage = "Product not available on App Store yet. Please check Apple Product IDs in Admin."
            return
        }
        
        let success = await storeKitManager.purchase(product: product, pack: pack)
        if success {
            successMessage = "Thank you! \(pack.name) credited to your account."
        }
    }
}
