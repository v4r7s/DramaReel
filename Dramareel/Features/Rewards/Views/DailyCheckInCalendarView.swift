import SwiftUI

public struct DailyCheckInCalendarView: View {
    public let dailyRewards: [Int]
    public let currentStreak: Int
    public let hasCheckedInToday: Bool
    public let isLoading: Bool
    public let onClaim: () -> Void
    
    public init(
        dailyRewards: [Int],
        currentStreak: Int,
        hasCheckedInToday: Bool,
        isLoading: Bool,
        onClaim: @escaping () -> Void
    ) {
        self.dailyRewards = dailyRewards
        self.currentStreak = currentStreak
        self.hasCheckedInToday = hasCheckedInToday
        self.isLoading = isLoading
        self.onClaim = onClaim
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(DramareelColors.goldAmber)
                    Text("Daily Check-In Streak")
                        .font(DramareelTypography.sectionTitle(size: 16))
                        .foregroundColor(.white)
                }
                Spacer()
                Text("Day \(currentStreak) of 7")
                    .font(DramareelTypography.tag(size: 11))
                    .foregroundColor(DramareelColors.coinGold)
            }
            
            // 7 Days Horizontal Stack
            HStack(spacing: 8) {
                ForEach(0..<min(7, dailyRewards.count), id: \.self) { dayIndex in
                    let dayNum = dayIndex + 1
                    let isClaimed = dayNum <= currentStreak
                    let isToday = dayNum == currentStreak + (hasCheckedInToday ? 0 : 1)
                    
                    VStack(spacing: 6) {
                        Text("Day \(dayNum)")
                            .font(DramareelTypography.tag(size: 9))
                            .foregroundColor(isClaimed ? DramareelColors.coinGold : DramareelColors.textSecondary)
                        
                        ZStack {
                            Circle()
                                .fill(isClaimed ? DramareelColors.coinGold.opacity(0.2) : DramareelColors.surfaceCard)
                                .frame(width: 38, height: 38)
                                .overlay(
                                    Circle()
                                        .stroke(
                                            isToday ? DramareelColors.coinGold :
                                            isClaimed ? DramareelColors.coinGold.opacity(0.5) :
                                            DramareelColors.surfaceBorder,
                                            lineWidth: isToday ? 1.5 : 1
                                        )
                                )
                            
                            if isClaimed {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(DramareelColors.coinGold)
                            } else {
                                Image(systemName: "circle.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(DramareelColors.coinGold)
                            }
                        }
                        
                        Text("+\(dailyRewards[dayIndex])")
                            .font(DramareelTypography.tag(size: 10))
                            .foregroundColor(isClaimed ? DramareelColors.coinGold : .white)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            
            // Claim Button
            DramareelButton(
                title: hasCheckedInToday ? "Checked In Today" : "Claim Today's Coins",
                icon: hasCheckedInToday ? "checkmark.circle.fill" : "gift.fill",
                style: hasCheckedInToday ? .secondaryGlass : .coinGold,
                isLoading: isLoading,
                action: {
                    if !hasCheckedInToday {
                        onClaim()
                    }
                }
            )
            .disabled(hasCheckedInToday)
        }
        .padding(18)
        .background(DramareelColors.surfaceCard)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(DramareelColors.surfaceBorder, lineWidth: 1))
        .padding(.horizontal, 16)
    }
}

public struct RewardTaskRowView: View {
    public let task: RewardTask
    public let isClaimed: Bool
    public let onPerform: () -> Void
    
    public init(task: RewardTask, isClaimed: Bool, onPerform: @escaping () -> Void) {
        self.task = task
        self.isClaimed = isClaimed
        self.onPerform = onPerform
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            // Task Icon
            ZStack {
                Circle()
                    .fill(task.type == "ad" ? DramareelColors.neonPink.opacity(0.15) : DramareelColors.electricCyan.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: task.type == "ad" ? "play.rectangle.fill" : "link")
                    .font(.system(size: 16))
                    .foregroundColor(task.type == "ad" ? DramareelColors.neonPink : DramareelColors.electricCyan)
            }
            
            // Title & Reward
            VStack(alignment: .leading, spacing: 3) {
                Text(task.title)
                    .font(DramareelTypography.dramaTitle(size: 14))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Image(systemName: "circle.circle.fill")
                        .font(.system(size: 10))
                        .foregroundColor(DramareelColors.coinGold)
                    Text("+\(task.coins) Coins")
                        .font(DramareelTypography.tag(size: 11))
                        .foregroundColor(DramareelColors.coinGold)
                }
            }
            
            Spacer()
            
            // Action Button
            Button(action: onPerform) {
                Text(isClaimed ? "Done" : (task.type == "ad" ? "Watch" : "Go"))
                    .font(DramareelTypography.button(size: 12))
                    .foregroundColor(isClaimed ? DramareelColors.textMuted : .white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 7)
                    .background(
                        isClaimed ?
                        AnyView(Color.white.opacity(0.06)) :
                        AnyView(DramareelColors.actionGradient)
                    )
                    .cornerRadius(14)
            }
            .disabled(isClaimed)
        }
        .padding(14)
        .background(DramareelColors.surfaceCard)
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(DramareelColors.surfaceBorder, lineWidth: 1))
        .padding(.horizontal, 16)
    }
}
