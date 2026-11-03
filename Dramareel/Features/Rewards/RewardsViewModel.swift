import Foundation
import SwiftUI

@MainActor
public final class RewardsViewModel: ObservableObject {
    @Published public var dailyRewards: [Int] = [10, 15, 20, 25, 30, 40, 50]
    @Published public var currentStreak: Int = 0
    @Published public var hasCheckedInToday: Bool = false
    @Published public var rewardTasks: [RewardTask] = []
    @Published public var claimedTaskIds: Set<String> = []
    @Published public var referralCodeInput: String = ""
    @Published public var referralClaimMessage: String? = nil
    @Published public var isClaimingCheckIn: Bool = false
    @Published public var isClaimingReferral: Bool = false
    @Published public var alertMessage: String? = nil
    @Published public var showAlert: Bool = false
    
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
        self.claimedTaskIds = localStorage.getClaimedTaskIds()
    }
    
    public func loadRewardsData() async {
        do {
            let settings: AppSettings = try await apiClient.request(.settings(platform: "ios"))
            self.dailyRewards = settings.dailyRewards
            self.rewardTasks = settings.rewardTasks
        } catch {
            #if DEBUG
            print("Failed to load settings: \(error)")
            #endif
        }
        
        if let user = authService.currentUser {
            self.currentStreak = user.consecutiveCheckInDays
            self.claimedTaskIds = Set(user.claimedTaskIds)
            
            // Check if checked in today
            let today = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
            self.hasCheckedInToday = user.lastCheckInDate == today
        }
    }
    
    // MARK: - Daily Check-In
    public func performCheckIn() async {
        guard let uid = authService.currentUser?.uid else {
            alertMessage = "Please sign in to claim daily rewards."
            showAlert = true
            return
        }
        
        isClaimingCheckIn = true
        defer { isClaimingCheckIn = false }
        
        do {
            let data = try await apiClient.requestRaw(.checkIn(uid: uid))
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let success = json["success"] as? Bool, success {
                let reward = json["reward"] as? Int ?? 10
                let dayNum = json["dayNum"] as? Int ?? 1
                let updatedCoins = json["coins"] as? Int ?? (authService.currentUser?.coins ?? 0)
                
                authService.currentUser?.coins = updatedCoins
                authService.currentUser?.consecutiveCheckInDays = dayNum
                self.currentStreak = dayNum
                self.hasCheckedInToday = true
                
                alertMessage = "Day \(dayNum) Check-In successful! You earned +\(reward) coins."
                showAlert = true
            } else {
                alertMessage = "Check-in failed. Please try again tomorrow."
                showAlert = true
            }
        } catch {
            alertMessage = error.localizedDescription
            showAlert = true
        }
    }
    
    // MARK: - Claim Task
    public func claimTask(task: RewardTask) async {
        guard let uid = authService.currentUser?.uid else {
            alertMessage = "Please sign in to claim task rewards."
            showAlert = true
            return
        }
        
        do {
            let data = try await apiClient.requestRaw(.claimReward(uid: uid, taskId: task.id))
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let success = json["success"] as? Bool, success {
                claimedTaskIds.insert(task.id)
                localStorage.markTaskClaimed(taskId: task.id)
                authService.currentUser?.coins += task.coins
                alertMessage = "Task completed! Earned +\(task.coins) coins."
                showAlert = true
            }
        } catch {
            alertMessage = error.localizedDescription
            showAlert = true
        }
    }
    
    // MARK: - Claim Referral
    public func claimReferral() async {
        let code = referralCodeInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !code.isEmpty else { return }
        guard let uid = authService.currentUser?.uid else {
            referralClaimMessage = "Please sign in first."
            return
        }
        
        isClaimingReferral = true
        defer { isClaimingReferral = false }
        
        do {
            let data = try await apiClient.requestRaw(.claimReferral(userId: uid, code: code))
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                if let success = json["success"] as? Bool, success {
                    let bonus = (json["coinsAwarded"] as? Int) ?? (json["bonusCoins"] as? Int) ?? 30
                    authService.currentUser?.coins += bonus
                    referralClaimMessage = "Referral redeemed! Earned +\(bonus) coins."
                    referralCodeInput = ""
                } else {
                    referralClaimMessage = json["error"] as? String ?? "Failed to redeem code."
                }
            }
        } catch {
            referralClaimMessage = error.localizedDescription
        }
    }
}
