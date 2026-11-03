import SwiftUI
import AuthenticationServices

public struct LoginView: View {
    @ObservedObject var authService: AuthService = .shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isShowingRegister: Bool = false
    @State private var isShowingForgotPassword: Bool = false
    @State private var alertMessage: String? = nil
    @State private var showAlert: Bool = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                DramareelColors.backgroundDark
                    .ignoresSafeArea()
                
                // Subtle ambient glow
                VStack {
                    Circle()
                        .fill(DramareelColors.primaryPurple.opacity(0.18))
                        .blur(radius: 70)
                        .frame(width: 280, height: 280)
                        .offset(y: -100)
                    Spacer()
                }
                .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        Spacer().frame(height: 20)
                        
                        // Dramareel Logo
                        DramareelLogoView(size: 52, showWordmark: true, showSlogan: true)
                            .padding(.bottom, 10)
                        
                        // Welcome text
                        VStack(spacing: 6) {
                            Text("Welcome Back")
                                .font(DramareelTypography.heroTitle(size: 26))
                                .foregroundColor(DramareelColors.textPrimary)
                            Text("Sign in to continue watching your drama reels")
                                .font(DramareelTypography.body(size: 13))
                                .foregroundColor(DramareelColors.textSecondary)
                        }
                        
                        // Input Fields Glass Container
                        VStack(spacing: 16) {
                            // Email
                            HStack(spacing: 12) {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(DramareelColors.neonPink)
                                    .frame(width: 20)
                                TextField("Email Address", text: $email)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .foregroundColor(.white)
                            }
                            .padding(14)
                            .background(DramareelColors.surfaceCard)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(DramareelColors.surfaceBorder, lineWidth: 1))
                            
                            // Password
                            HStack(spacing: 12) {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(DramareelColors.electricCyan)
                                    .frame(width: 20)
                                SecureField("Password", text: $password)
                                    .foregroundColor(.white)
                            }
                            .padding(14)
                            .background(DramareelColors.surfaceCard)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(DramareelColors.surfaceBorder, lineWidth: 1))
                            
                            // Forgot Password Button
                            HStack {
                                Spacer()
                                Button(action: { isShowingForgotPassword = true }) {
                                    Text("Forgot Password?")
                                        .font(DramareelTypography.caption(size: 12))
                                        .foregroundColor(DramareelColors.neonPink)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Sign In Button
                        DramareelButton(
                            title: "Sign In",
                            icon: "arrow.right.circle.fill",
                            style: .primaryGradient,
                            isLoading: authService.isLoading,
                            action: handleEmailSignIn
                        )
                        .padding(.horizontal, 20)
                        
                        // Divider
                        HStack {
                            Rectangle().fill(DramareelColors.surfaceBorder).frame(height: 1)
                            Text("OR")
                                .font(DramareelTypography.tag(size: 11))
                                .foregroundColor(DramareelColors.textMuted)
                                .padding(.horizontal, 8)
                            Rectangle().fill(DramareelColors.surfaceBorder).frame(height: 1)
                        }
                        .padding(.horizontal, 20)
                        
                        // Sign in with Apple
                        SignInWithAppleButton(.signIn) { request in
                            // Configured in AppleSignInCoordinator
                        } onCompletion: { _ in
                            Task {
                                let success = await authService.signInWithApple()
                                if success {
                                    dismiss()
                                }
                            }
                        }
                        .signInWithAppleButtonStyle(.white)
                        .frame(height: 50)
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                        
                        // Don't have an account? Sign Up
                        HStack(spacing: 4) {
                            Text("Don't have an account?")
                                .font(DramareelTypography.body(size: 13))
                                .foregroundColor(DramareelColors.textSecondary)
                            Button(action: { isShowingRegister = true }) {
                                Text("Sign Up")
                                    .font(DramareelTypography.button(size: 13))
                                    .foregroundColor(DramareelColors.electricCyan)
                            }
                        }
                        .padding(.top, 10)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationDestination(isPresented: $isShowingRegister) {
                RegisterView()
            }
            .sheet(isPresented: $isShowingForgotPassword) {
                ForgotPasswordView()
            }
            .alert("Sign In", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage ?? "An error occurred.")
            }
        }
    }
    
    private func handleEmailSignIn() {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty, !password.isEmpty else {
            alertMessage = "Please enter both your email and password."
            showAlert = true
            return
        }
        
        Task {
            let success = await authService.signIn(email: email.trimmingCharacters(in: .whitespaces), password: password)
            if success {
                dismiss()
            } else if let error = authService.errorMessage {
                alertMessage = error
                showAlert = true
            }
        }
    }
}
