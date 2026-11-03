import SwiftUI

public struct ProfileView: View {
    @ObservedObject var authService: AuthService = .shared
    @StateObject private var viewModel = UserAccountViewModel()
    
    public let allDramas: [Drama]
    public let onSelectDrama: (Drama) -> Void
    public let onOpenStore: () -> Void
    public let onOpenLogin: () -> Void
    
    @State private var isShowingDeleteDialog: Bool = false
    @State private var isShowingSettingsSheet: Bool = false
    
    public init(
        allDramas: [Drama],
        onSelectDrama: @escaping (Drama) -> Void,
        onOpenStore: @escaping () -> Void,
        onOpenLogin: @escaping () -> Void
    ) {
        self.allDramas = allDramas
        self.onSelectDrama = onSelectDrama
        self.onOpenStore = onOpenStore
        self.onOpenLogin = onOpenLogin
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                DramareelColors.backgroundDark
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // User Profile Card
                        userHeaderCard
                        
                        // Coin Wallet Card
                        walletCard
                        
                        // Menu Section
                        menuSection
                        
                        // App Version & Legal
                        VStack(spacing: 4) {
                            Text("\(AppConstants.appName) v1.0.0 (Build 1)")
                                .font(DramareelTypography.tag(size: 11))
                                .foregroundColor(DramareelColors.textMuted)
                            Text(AppConstants.appSlogan)
                                .font(DramareelTypography.tag(size: 10))
                                .foregroundColor(DramareelColors.textMuted)
                        }
                        .padding(.top, 10)
                        
                        Spacer().frame(height: 50)
                    }
                    .padding(.top, 10)
                }
            }
            .navigationTitle("My Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isShowingSettingsSheet = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 16))
                            .foregroundColor(DramareelColors.textSecondary)
                    }
                }
            }
            .sheet(isPresented: $isShowingSettingsSheet) {
                serverSettingsSheet
            }
            .alert("Delete Account", isPresented: $isShowingDeleteDialog) {
                Button("Cancel", role: .cancel) {}
                Button("Delete Permanently", role: .destructive) {
                    Task {
                        _ = await authService.deleteAccount()
                    }
                }
            } message: {
                Text("Are you sure you want to permanently delete your Dramareel account? All purchased coins, history, and unlocked episodes will be permanently erased. This action cannot be undone.")
            }
            .task {
                await viewModel.loadUserData(allDramas: allDramas)
            }
        }
    }
    
    // MARK: - User Header
    private var userHeaderCard: some View {
        HStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [DramareelColors.primaryPurple, DramareelColors.neonPink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                if let urlString = authService.currentUser?.photoURL, let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Text(String(authService.currentUser?.displayName?.prefix(1) ?? "D"))
                            .font(DramareelTypography.heroTitle(size: 22))
                            .foregroundColor(.white)
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                } else {
                    Text(String(authService.currentUser?.displayName?.prefix(1) ?? "U"))
                        .font(DramareelTypography.heroTitle(size: 22))
                        .foregroundColor(.white)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                if let user = authService.currentUser {
                    HStack(spacing: 6) {
                        Text(user.displayName ?? "Dramareel User")
                            .font(DramareelTypography.heroTitle(size: 18))
                            .foregroundColor(.white)
                        
                        if user.isVipActive {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 14))
                                .foregroundColor(DramareelColors.coinGold)
                        }
                    }
                    
                    Text(user.email ?? "Signed In")
                        .font(DramareelTypography.body(size: 12))
                        .foregroundColor(DramareelColors.textSecondary)
                    
                    if let pubId = user.publicId, !pubId.isEmpty {
                        Text("ID: \(pubId)")
                            .font(DramareelTypography.tag(size: 10))
                            .foregroundColor(DramareelColors.textMuted)
                    }
                } else {
                    Text("Guest User")
                        .font(DramareelTypography.heroTitle(size: 18))
                        .foregroundColor(.white)
                    Text("Sign in to sync your coin wallet & history")
                        .font(DramareelTypography.body(size: 12))
                        .foregroundColor(DramareelColors.textSecondary)
                }
            }
            
            Spacer()
            
            if authService.currentUser == nil {
                Button(action: onOpenLogin) {
                    Text("Sign In")
                        .font(DramareelTypography.button(size: 13))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(DramareelColors.actionGradient)
                        .cornerRadius(12)
                }
            }
        }
        .padding(18)
        .background(DramareelColors.surfaceCard)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(DramareelColors.surfaceBorder, lineWidth: 1))
        .padding(.horizontal, 16)
    }
    
    // MARK: - Wallet Card
    private var walletCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("COIN BALANCE")
                    .font(DramareelTypography.tag(size: 10))
                    .foregroundColor(DramareelColors.textSecondary)
                HStack(spacing: 8) {
                    Image(systemName: "circle.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(DramareelColors.coinGold)
                    Text("\(authService.currentUser?.coins ?? 0)")
                        .font(.system(size: 26, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Text("Coins")
                        .font(DramareelTypography.body(size: 14))
                        .foregroundColor(DramareelColors.coinGold)
                }
            }
            Spacer()
            Button(action: onOpenStore) {
                HStack(spacing: 5) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 13))
                    Text("Top Up")
                        .font(DramareelTypography.button(size: 13))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 9)
                .background(DramareelColors.coinGoldGradient)
                .cornerRadius(12)
            }
        }
        .padding(18)
        .background(DramareelColors.surfaceCard)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(DramareelColors.surfaceBorder, lineWidth: 1))
        .padding(.horizontal, 16)
    }
    
    // MARK: - Menu Section
    private var menuSection: some View {
        VStack(spacing: 2) {
            NavigationLink(destination: WatchHistoryView(viewModel: viewModel, allDramas: allDramas, onSelectDrama: onSelectDrama)) {
                menuRow(icon: "clock.arrow.circlepath", title: "Watch History", badge: "\(viewModel.historyItems.count)")
            }
            
            NavigationLink(destination: FavoritesView(viewModel: viewModel, onSelectDrama: onSelectDrama)) {
                menuRow(icon: "bookmark.fill", title: "My Watchlist", badge: "\(viewModel.favoriteDramas.count)")
            }
            
            NavigationLink(destination: TransactionHistoryView(viewModel: viewModel)) {
                menuRow(icon: "list.bullet.rectangle.portrait.fill", title: "Coin Transactions")
            }
            
            // Sign Out
            if authService.currentUser != nil {
                Button(action: { authService.signOut() }) {
                    menuRow(icon: "rectangle.portrait.and.arrow.right", title: "Log Out", tint: DramareelColors.neonPink)
                }
                
                // Delete Account
                Button(action: { isShowingDeleteDialog = true }) {
                    menuRow(icon: "trash.fill", title: "Delete Account", tint: DramareelColors.errorRed)
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    private func menuRow(icon: String, title: String, badge: String? = nil, tint: Color = .white) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(tint == .white ? DramareelColors.neonPink : tint)
                .frame(width: 24)
            
            Text(title)
                .font(DramareelTypography.body(size: 14))
                .foregroundColor(tint)
            
            Spacer()
            
            if let badge = badge {
                Text(badge)
                    .font(DramareelTypography.tag(size: 11))
                    .foregroundColor(DramareelColors.textSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(DramareelColors.surfaceGlass)
                    .cornerRadius(8)
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(DramareelColors.textMuted)
        }
        .padding(16)
        .background(DramareelColors.surfaceCard)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(DramareelColors.surfaceBorder, lineWidth: 1))
        .padding(.vertical, 4)
    }
    
    // Server Settings Sheet for VPS / Development overrides
    private var serverSettingsSheet: some View {
        NavigationStack {
            ZStack {
                DramareelColors.surfaceCard
                    .ignoresSafeArea()
                
                Form {
                    Section(header: Text("SERVER CONFIGURATION").foregroundColor(DramareelColors.neonPink)) {
                        TextField("API Base URL", text: Binding(
                            get: { APIClient.shared.baseURL },
                            set: { APIClient.shared.baseURL = $0 }
                        ))
                        .autocapitalization(.none)
                        
                        TextField("API Key", text: Binding(
                            get: { APIClient.shared.apiKey },
                            set: { APIClient.shared.apiKey = $0 }
                        ))
                    }
                    
                    Section(footer: Text("Changes are saved automatically. Enter your VPS or production Next.js domain.").foregroundColor(DramareelColors.textMuted)) {
                        Button("Reset to Default") {
                            APIClient.shared.baseURL = AppConstants.defaultBaseURL
                            APIClient.shared.apiKey = AppConstants.defaultApiKey
                        }
                        .foregroundColor(DramareelColors.errorRed)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Developer Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { isShowingSettingsSheet = false }
                        .foregroundColor(DramareelColors.electricCyan)
                }
            }
        }
    }
}
