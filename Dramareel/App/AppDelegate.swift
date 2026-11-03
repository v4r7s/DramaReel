import UIKit
import UserNotifications
import FirebaseCore
import OneSignalFramework

public class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    public func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        // Initialize Firebase
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
        // Setup APNs Notifications
        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()
        
        // Initialize OneSignal if App ID is configured
        let oneSignalAppId = UserDefaults.standard.string(forKey: "onesignal_app_id") ?? ""
        if !oneSignalAppId.isEmpty {
            OneSignal.initialize(oneSignalAppId, withLaunchOptions: launchOptions)
        }
        
        return true
    }
    
    // MARK: - APNs Registration
    public func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        #if DEBUG
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        #endif
    }
    
    public func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        #if DEBUG
        print("Failed to register for remote notifications: \(error)")
        #endif
    }
    
    // MARK: - Foreground Notification Presentation
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .badge, .sound])
    }
}
