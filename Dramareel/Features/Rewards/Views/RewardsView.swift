import SwiftUI

public struct ReferralCardView: View {
    public let referralCode: String
    @Binding var inputCode: String
    public let isClaiming: Bool
    public let statusMessage: String?
    public let onClaimCode: () -> Void
    public let onShareCode: () -> Void
    
    public init(
        referralCode: String,
        inputCode: Binding<String>,
        isClaiming: Bool,
        statusMessage: String?,
        onClaimCode: @escaping () -> Void,
        onShareCode: @escaping () -> Void
    ) {
        self.referralCode = referralCode
        self._inputCode = inputCode
        self.isClaiming = isClaiming
        self.statusMessage = statusMessage
        self.onClaimCode = onClaimCode
        self.onShareCode = onShareCode
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "person.2.fill")
                        .foregroundColor(DramareelColors.electricCyan)
                    Text("Invite Friends & Earn")
                        .font(DramareelTypography.sectionTitle(size: 16))
                        .foregroundColor(.white)
                }
                Spacer()
                Text("+50 Coins")
                    .font(DramareelTypography.tag(size: 11))
                    .foregroundColor(DramareelColors.coinGold)
            }
            
            Text("Share your unique referral code with friends. When they register, you both get bonus coins!")
                .font(DramareelTypography.body(size: 12))
                .foregroundColor(DramareelColors.textSecondary)
                .lineSpacing(2)
            
            // Your Code Box
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("YOUR CODE")
                        .font(DramareelTypography.tag(size: 9))
                        .foregroundColor(DramareelColors.textMuted)
                    Text(referralCode.isEmpty ? "SNAP-XXXXXX" : referralCode)
                        .font(.system(size: 18, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                }
                Spacer()
                Button(action: onShareCode) {
                    HStack(spacing: 5) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 13, weight: .bold))
                        Text("Share")
                            .font(DramareelTypography.button(size: 13))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(DramareelColors.actionGradient)
                    .cornerRadius(10)
                }
            }
            .padding(12)
            .background(DramareelColors.surfaceGlass)
            .cornerRadius(12)
            
            // Enter Friend's Code
            VStack(alignment: .leading, spacing: 6) {
                Text("HAVE A FRIEND'S CODE?")
                    .font(DramareelTypography.tag(size: 9))
                    .foregroundColor(DramareelColors.textMuted)
                
                HStack(spacing: 8) {
                    TextField("Enter Referral Code", text: $inputCode)
                        .autocapitalization(.allCharacters)
                        .foregroundColor(.white)
                        .padding(10)
                        .background(DramareelColors.surfaceGlass)
                        .cornerRadius(10)
                    
                    DramareelButton(
                        title: "Redeem",
                        style: .coinGold,
                        isLoading: isClaiming,
                        isFullWidth: false,
                        action: onClaimCode
                    )
                }
                
                if let message = statusMessage {
                    Text(message)
                        .font(DramareelTypography.caption(size: 11))
                        .foregroundColor(DramareelColors.electricCyan)
                }
            }
        }
        .padding(18)
        .background(DramareelColors.surfaceCard)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(DramareelColors.surfaceBorder, lineWidth: 1))
        .padding(.horizontal, 16)
    }
}

public struct RewardsView: View {
    @StateObject private var viewModel = RewardsViewModel()
    @ObservedObject var authService: AuthService = .shared
    public let onWatchAdReward: (@escaping () -> Void) -> Void
    
    public init(onWatchAdReward: @escaping (@escaping () -> Void) -> Void) {
        self.onWatchAdReward = onWatchAdReward
    }
    
    public var body: some View {
        ZStack {
            DramareelColors.backgroundDark
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    // Header Bar
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Rewards Center")
                                .font(DramareelTypography.heroTitle(size: 24))
                                .foregroundColor(.white)
                            Text("Earn free coins daily to unlock drama reels")
                                .font(DramareelTypography.body(size: 12))
                                .foregroundColor(DramareelColors.textSecondary)
                        }
                        Spacer()
                        
                        // Current Coins Pill
                        HStack(spacing: 6) {
                            Image(systemName: "circle.circle.fill")
                                .font(.system(size: 15))
                                .foregroundColor(DramareelColors.coinGold)
                            Text("\(authService.currentUser?.coins ?? 0)")
                                .font(DramareelTypography.button(size: 15))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(DramareelColors.surfaceCard)
                        .cornerRadius(20)
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(DramareelColors.coinGold.opacity(0.4), lineWidth: 1))
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    
                    // Daily Check-In Calendar
                    DailyCheckInCalendarView(
                        dailyRewards: viewModel.dailyRewards,
                        currentStreak: viewModel.currentStreak,
                        hasCheckedInToday: viewModel.hasCheckedInToday,
                        isLoading: viewModel.isClaimingCheckIn,
                        onClaim: {
                            Task { await viewModel.performCheckIn() }
                        }
                    )
                    
                    // Referral Card
                    ReferralCardView(
                        referralCode: authService.currentUser?.referralCode ?? "",
                        inputCode: $viewModel.referralCodeInput,
                        isClaiming: viewModel.isClaimingReferral,
                        statusMessage: viewModel.referralClaimMessage,
                        onClaimCode: {
                            Task { await viewModel.claimReferral() }
                        },
                        onShareCode: shareReferralCode
                    )
                    
                    // Reward Tasks Section
                    if !viewModel.rewardTasks.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Complete Tasks")
                                .font(DramareelTypography.sectionTitle(size: 16))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                            
                            ForEach(viewModel.rewardTasks) { task in
                                RewardTaskRowView(
                                    task: task,
                                    isClaimed: viewModel.claimedTaskIds.contains(task.id),
                                    onPerform: {
                                        handlePerformTask(task)
                                    }
                                )
                            }
                        }
                    }
                    
                    Spacer().frame(height: 60)
                }
            }
        }
        .alert("Rewards", isPresented: $viewModel.showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.alertMessage ?? "")
        }
        .task {
            await viewModel.loadRewardsData()
        }
    }
    
    private func handlePerformTask(_ task: RewardTask) {
        if task.type == "ad" {
            onWatchAdReward {
                Task {
                    await viewModel.claimTask(task: task)
                }
            }
        } else if let url = URL(string: task.url) {
            UIApplication.shared.open(url)
            Task {
                try? await Task.sleep(nanoseconds: UInt64(task.timerSeconds) * 1_000_000_000)
                await viewModel.claimTask(task: task)
            }
        }
    }
    
    private func shareReferralCode() {
        let code = authService.currentUser?.referralCode ?? ""
        let shareText = "Join me on Dramareel to watch exciting short drama reels! Use my invite code \(code) to get 50 free bonus coins: \(AppConstants.defaultBaseURL)"
        let av = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = windowScene.windows.first?.rootViewController {
            root.present(av, animated: true)
        }
    }
}
