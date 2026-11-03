import SwiftUI
import StoreKit

public struct CoinPackCard: View {
    public let pack: CoinPack
    public let product: Product?
    public let isPurchasing: Bool
    public let onPurchase: () -> Void
    
    public init(pack: CoinPack, product: Product?, isPurchasing: Bool, onPurchase: @escaping () -> Void) {
        self.pack = pack
        self.product = product
        self.isPurchasing = isPurchasing
        self.onPurchase = onPurchase
    }
    
    public var body: some View {
        VStack(spacing: 12) {
            // Coin Icon Stack
            ZStack {
                Circle()
                    .fill(DramareelColors.coinGold.opacity(0.15))
                    .frame(width: 52, height: 52)
                Image(systemName: "circle.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(DramareelColors.coinGold)
            }
            .padding(.top, 4)
            
            // Coin Amount
            VStack(spacing: 2) {
                Text("\(pack.amount)")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text("Coins")
                    .font(DramareelTypography.tag(size: 11))
                    .foregroundColor(DramareelColors.textSecondary)
            }
            
            // Price Button
            Button(action: onPurchase) {
                Text(product?.displayPrice ?? String(format: "$%.2f", pack.price))
                    .font(DramareelTypography.button(size: 13))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(DramareelColors.coinGoldGradient)
                    .cornerRadius(10)
            }
            .disabled(isPurchasing)
        }
        .padding(14)
        .background(DramareelColors.surfaceCard)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(DramareelColors.coinGold.opacity(0.35), lineWidth: 1)
        )
    }
}

public struct StoreView: View {
    @StateObject private var viewModel = StoreViewModel()
    @ObservedObject var authService: AuthService = .shared
    @Environment(\.dismiss) private var dismiss
    
    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                DramareelColors.backgroundDark
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        // Current Balance Card
                        balanceHeaderCard
                        
                        // VIP Membership Banner
                        vipMembershipSection
                        
                        // Coin Packs Grid
                        coinPacksSection
                        
                        // Restore Purchases
                        Button(action: {
                            Task { _ = await viewModel.storeKitManager.restorePurchases() }
                        }) {
                            Text("Restore In-App Purchases")
                                .font(DramareelTypography.caption(size: 12))
                                .foregroundColor(DramareelColors.textSecondary)
                                .underline()
                        }
                        .padding(.top, 8)
                        
                        // Terms Note
                        Text("Payment will be charged to your Apple ID account at confirmation of purchase. Consumable coins never expire.")
                            .font(DramareelTypography.tag(size: 10))
                            .foregroundColor(DramareelColors.textMuted)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 20)
                    }
                    .padding(.top, 10)
                }
            }
            .navigationTitle("Coin Store")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(DramareelColors.electricCyan)
                }
            }
            .alert("Store", isPresented: Binding(
                get: { viewModel.errorMessage != nil || viewModel.successMessage != nil },
                set: { _ in
                    viewModel.errorMessage = nil
                    viewModel.successMessage = nil
                }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? viewModel.successMessage ?? "")
            }
            .task {
                await viewModel.loadPacks()
            }
        }
    }
    
    // Balance Card
    private var balanceHeaderCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("CURRENT BALANCE")
                    .font(DramareelTypography.tag(size: 10))
                    .foregroundColor(DramareelColors.textSecondary)
                HStack(spacing: 8) {
                    Image(systemName: "circle.circle.fill")
                        .font(.system(size: 26))
                        .foregroundColor(DramareelColors.coinGold)
                    Text("\(authService.currentUser?.coins ?? 0)")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Text("Coins")
                        .font(DramareelTypography.body(size: 15))
                        .foregroundColor(DramareelColors.coinGold)
                }
            }
            Spacer()
            
            // VIP status tag
            if authService.currentUser?.isVipActive == true {
                VStack(spacing: 2) {
                    Text("VIP ACTIVE")
                        .font(DramareelTypography.tag(size: 10))
                        .foregroundColor(DramareelColors.neonPink)
                    Image(systemName: "crown.fill")
                        .foregroundColor(DramareelColors.coinGold)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(DramareelColors.surfaceGlass)
                .cornerRadius(10)
            }
        }
        .padding(18)
        .background(DramareelColors.surfaceCard)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(DramareelColors.surfaceBorder, lineWidth: 1))
        .padding(.horizontal, 16)
    }
    
    // VIP Membership Section
    private var vipMembershipSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("VIP Pass")
                .font(DramareelTypography.sectionTitle(size: 16))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
            
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 22))
                            .foregroundColor(DramareelColors.coinGold)
                        Text("Unlimited VIP Access")
                            .font(DramareelTypography.heroTitle(size: 18))
                            .foregroundColor(.white)
                    }
                    
                    Text("Stream all drama episodes completely unlocked without spending coins or watching ads.")
                        .font(DramareelTypography.body(size: 12))
                        .foregroundColor(DramareelColors.textSecondary)
                        .lineSpacing(2)
                    
                    if let vipPack = viewModel.membershipPacks.first {
                        let product = viewModel.storeKitManager.products.first(where: { $0.id == vipPack.appleProductId })
                        DramareelButton(
                            title: "Get VIP for \(product?.displayPrice ?? String(format: "$%.2f", vipPack.price))",
                            icon: "sparkles",
                            style: .primaryGradient,
                            isLoading: viewModel.storeKitManager.isPurchasing
                        ) {
                            Task { await viewModel.purchasePack(vipPack) }
                        }
                        .padding(.top, 4)
                    }
                }
                .padding(18)
                .background(
                    LinearGradient(
                        colors: [
                            DramareelColors.surfaceCard,
                            DramareelColors.primaryPurple.opacity(0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(DramareelColors.neonPink.opacity(0.4), lineWidth: 1)
                )
                .padding(.horizontal, 16)
            }
        }
    }
    
    // Coin Packs Section
    private var coinPacksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Coin Packs")
                .font(DramareelTypography.sectionTitle(size: 16))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
            
            if viewModel.isLoading && viewModel.coinPacks.isEmpty {
                LoadingStateView(message: "Loading Store Packages...")
                    .frame(height: 140)
            } else if viewModel.coinPacks.isEmpty {
                EmptyStateView(
                    icon: "cart",
                    title: "No Coin Packs",
                    message: "Coin packages will appear here once configured in the Admin Panel."
                )
            } else {
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(viewModel.coinPacks) { pack in
                        let product = viewModel.storeKitManager.products.first(where: { $0.id == pack.appleProductId })
                        CoinPackCard(
                            pack: pack,
                            product: product,
                            isPurchasing: viewModel.storeKitManager.isPurchasing
                        ) {
                            Task { await viewModel.purchasePack(pack) }
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}
