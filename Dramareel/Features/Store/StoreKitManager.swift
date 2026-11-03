import Foundation
import StoreKit

@MainActor
public final class StoreKitManager: ObservableObject {
    public static let shared = StoreKitManager()
    
    @Published public var products: [Product] = []
    @Published public var purchasedProductIDs = Set<String>()
    @Published public var isPurchasing: Bool = false
    @Published public var errorMessage: String? = nil
    
    private let apiClient: APIClient
    private let authService: AuthService
    private var updateListenerTask: Task<Void, Error>?
    
    public init(apiClient: APIClient = .shared, authService: AuthService = .shared) {
        self.apiClient = apiClient
        self.authService = authService
        
        // Start listening for transaction updates (StoreKit 2)
        updateListenerTask = listenForTransactions()
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Transaction Listener
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await self.handleVerifiedTransaction(transaction, jwsRepresentation: result.jwsRepresentation)
                    await transaction.finish()
                } catch {
                    #if DEBUG
                    print("Transaction verification failed: \(error)")
                    #endif
                }
            }
        }
    }
    
    // MARK: - Fetch Products
    public func fetchProducts(productIdentifiers: [String]) async {
        guard !productIdentifiers.isEmpty else { return }
        
        do {
            let storeProducts = try await Product.products(for: productIdentifiers)
            self.products = storeProducts
        } catch {
            #if DEBUG
            print("Failed to fetch StoreKit products: \(error)")
            #endif
        }
    }
    
    // MARK: - Purchase Product
    public func purchase(product: Product, pack: CoinPack) async -> Bool {
        guard let uid = authService.currentUser?.uid else {
            errorMessage = "Please sign in to purchase coins."
            return false
        }
        
        isPurchasing = true
        errorMessage = nil
        defer { isPurchasing = false }
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                
                // Submit signed transaction JWS to backend for verification
                let verifiedOnServer = await verifyWithBackend(
                    uid: uid,
                    packId: pack.id,
                    jwsString: verification.jwsRepresentation
                )
                
                if verifiedOnServer {
                    await transaction.finish()
                    // Refresh user profile to show credited coins or VIP
                    await authService.fetchUserProfile(uid: uid)
                    return true
                } else {
                    errorMessage = "Server could not verify transaction. Please contact support."
                    return false
                }
                
            case .userCancelled:
                return false
                
            case .pending:
                errorMessage = "Purchase is pending parental or bank approval."
                return false
                
            @unknown default:
                return false
            }
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    // MARK: - Restore Purchases
    public func restorePurchases() async -> Bool {
        guard let uid = authService.currentUser?.uid else { return false }
        
        do {
            try await AppStore.sync()
            for await result in Transaction.currentEntitlements {
                if let transaction = try? checkVerified(result) {
                    _ = await verifyWithBackend(
                        uid: uid,
                        packId: transaction.productID,
                        jwsString: result.jwsRepresentation
                    )
                    await transaction.finish()
                }
            }
            await authService.fetchUserProfile(uid: uid)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    // MARK: - Verify With Backend
    private func verifyWithBackend(uid: String, packId: String, jwsString: String) async -> Bool {
        do {
            let data = try await apiClient.requestRaw(
                .verifyPurchase(
                    userId: uid,
                    packId: packId,
                    gateway: "apple",
                    sessionId: jwsString
                )
            )
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let success = json["success"] as? Bool {
                return success
            }
            return false
        } catch {
            #if DEBUG
            print("Backend purchase verification error: \(error)")
            #endif
            return false
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let safe):
            return safe
        }
    }
    
    private func handleVerifiedTransaction(_ transaction: Transaction, jwsRepresentation: String) async {
        guard let uid = authService.currentUser?.uid else { return }
        _ = await verifyWithBackend(uid: uid, packId: transaction.productID, jwsString: jwsRepresentation)
    }
}
