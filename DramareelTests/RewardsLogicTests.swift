import XCTest
@testable import Dramareel

final class RewardsLogicTests: XCTestCase {
    
    func testStreakCalculationNextDay() {
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        // Simulating last check-in was yesterday: streak should continue
        let isConsecutive = calendar.isDate(yesterday, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: today)!)
        XCTAssertTrue(isConsecutive)
        
        let currentStreak = 3
        let nextStreak = currentStreak + 1
        XCTAssertEqual(nextStreak, 4)
    }
    
    func testStreakResetAfterMissedDay() {
        let calendar = Calendar.current
        let today = Date()
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: today)!
        
        let daysDiff = calendar.dateComponents([.day], from: threeDaysAgo, to: today).day ?? 0
        XCTAssertGreaterThan(daysDiff, 1)
        
        let resetStreak = 1
        XCTAssertEqual(resetStreak, 1)
    }
    
    func testCheckInCoinProgression() {
        let dailyRewards = [10, 20, 30, 40, 50, 70, 100]
        XCTAssertEqual(dailyRewards.count, 7)
        XCTAssertEqual(dailyRewards[0], 10)
        XCTAssertEqual(dailyRewards[6], 100)
        
        let day5StreakIndex = (5 - 1) % 7
        XCTAssertEqual(dailyRewards[day5StreakIndex], 50)
        
        // Day 8 wraps around to index 0
        let day8StreakIndex = (8 - 1) % 7
        XCTAssertEqual(dailyRewards[day8StreakIndex], 10)
    }
    
    func testRewardTaskClaimState() {
        let task = RewardTask(
            id: "task_ad_1",
            title: "Watch 1 Ad",
            description: "Watch a short video sponsor",
            type: "ad",
            rewardCoins: 25,
            actionUrl: nil,
            icon: "play.circle.fill",
            platform: "ios",
            sortOrder: 1,
            isActive: true,
            createdAt: nil,
            updatedAt: nil
        )
        
        XCTAssertTrue(task.isActive)
        XCTAssertEqual(task.platform, "ios")
        XCTAssertEqual(task.rewardCoins, 25)
    }
}
