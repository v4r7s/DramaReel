import SwiftUI

@main
public struct DramareelApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var isShowingSplash: Bool = true
    
    public init() {}
    
    public var body: some Scene {
        WindowGroup {
            ZStack {
                DramareelColors.backgroundDark
                    .ignoresSafeArea()
                
                if isShowingSplash {
                    SplashScreenView()
                        .transition(.opacity)
                } else {
                    MainTabView()
                        .preferredColorScheme(.dark)
                        .transition(.opacity)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + AppConstants.splashDelaySeconds) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isShowingSplash = false
                    }
                }
            }
        }
    }
}
