import SwiftUI

public struct OnboardingSlide: Identifiable {
    public let id = UUID()
    public let icon: String
    public let title: String
    public let subtitle: String
    public let highlightColor: Color
}

public struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentStep: Int = 0
    
    private let slides: [OnboardingSlide] = [
        OnboardingSlide(
            icon: "play.tv.fill",
            title: "Binge Exclusive Short Dramas",
            subtitle: "Fast-paced, high-emotion vertical drama series crafted for modern streaming. New episodes added every day.",
            highlightColor: DramareelColors.neonPink
        ),
        OnboardingSlide(
            icon: "gift.fill",
            title: "Daily Check-Ins & Coin Rewards",
            subtitle: "Earn coins every single day, complete fun quick tasks, and unlock your favorite episodes for free.",
            highlightColor: DramareelColors.coinGold
        ),
        OnboardingSlide(
            icon: "sparkles.rectangle.stack.fill",
            title: "Ultra-Fast HD Streaming",
            subtitle: "Seamless playback with multi-language subtitles, continue watching, and premium cinema-grade vertical video.",
            highlightColor: DramareelColors.electricCyan
        )
    ]
    
    public init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
    
    public var body: some View {
        ZStack {
            DramareelColors.backgroundDark
                .ignoresSafeArea()
            
            // Atmospheric background glow
            VStack {
                Circle()
                    .fill(slides[currentStep].highlightColor.opacity(0.15))
                    .blur(radius: 90)
                    .frame(width: 320, height: 320)
                Spacer()
            }
            .ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Top Skip Button
                HStack {
                    DramareelLogoView(size: 34, showWordmark: true, showSlogan: false)
                    Spacer()
                    Button(action: finishOnboarding) {
                        Text("Skip")
                            .font(DramareelTypography.caption(size: 13))
                            .foregroundColor(DramareelColors.textSecondary)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                Spacer()
                
                // Slide Carousel
                TabView(selection: $currentStep) {
                    ForEach(0..<slides.count, id: \.self) { index in
                        VStack(spacing: 24) {
                            ZStack {
                                Circle()
                                    .fill(slides[index].highlightColor.opacity(0.12))
                                    .frame(width: 130, height: 130)
                                    .overlay(Circle().stroke(slides[index].highlightColor.opacity(0.3), lineWidth: 1.5))
                                
                                Image(systemName: slides[index].icon)
                                    .font(.system(size: 52))
                                    .foregroundColor(slides[index].highlightColor)
                            }
                            
                            VStack(spacing: 12) {
                                Text(slides[index].title)
                                    .font(DramareelTypography.heroTitle(size: 24))
                                    .foregroundColor(DramareelColors.textPrimary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                                
                                Text(slides[index].subtitle)
                                    .font(DramareelTypography.body(size: 14))
                                    .foregroundColor(DramareelColors.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(3)
                                    .padding(.horizontal, 32)
                            }
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                Spacer()
                
                // Bottom Page Indicators & Action
                VStack(spacing: 20) {
                    // Custom Indicators
                    HStack(spacing: 8) {
                        ForEach(0..<slides.count, id: \.self) { index in
                            Capsule()
                                .fill(index == currentStep ? DramareelColors.neonPink : DramareelColors.surfaceBorder)
                                .frame(width: index == currentStep ? 24 : 8, height: 8)
                                .animation(.spring(), value: currentStep)
                        }
                    }
                    
                    // Next / Get Started Button
                    DramareelButton(
                        title: currentStep == slides.count - 1 ? "Start Watching" : "Continue",
                        icon: currentStep == slides.count - 1 ? "play.circle.fill" : "arrow.right",
                        style: .primaryGradient,
                        action: {
                            if currentStep < slides.count - 1 {
                                withAnimation {
                                    currentStep += 1
                                }
                            } else {
                                finishOnboarding()
                            }
                        }
                    )
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 36)
            }
        }
    }
    
    private func finishOnboarding() {
        UserDefaults.standard.set(true, forKey: AppConstants.StorageKeys.hasCompletedOnboarding)
        withAnimation {
            isPresented = false
        }
    }
}
