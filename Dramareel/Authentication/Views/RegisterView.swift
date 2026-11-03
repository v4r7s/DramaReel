import SwiftUI

public struct RegisterView: View {
    @ObservedObject var authService: AuthService = .shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var displayName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var alertMessage: String? = nil
    @State private var showAlert: Bool = false
    
    public init() {}
    
    public var body: some View {
        ZStack {
            DramareelColors.backgroundDark
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    Spacer().frame(height: 10)
                    
                    DramareelLogoView(size: 46, showWordmark: true, showSlogan: false)
                    
                    VStack(spacing: 6) {
                        Text("Create Account")
                            .font(DramareelTypography.heroTitle(size: 24))
                            .foregroundColor(DramareelColors.textPrimary)
                        Text("Sign up to receive 100 free bonus coins")
                            .font(DramareelTypography.body(size: 13))
                            .foregroundColor(DramareelColors.coinGold)
                    }
                    
                    // Input Form
                    VStack(spacing: 14) {
                        // Display Name
                        HStack(spacing: 12) {
                            Image(systemName: "person.fill")
                                .foregroundColor(DramareelColors.electricCyan)
                                .frame(width: 20)
                            TextField("Full Name / Nickname", text: $displayName)
                                .foregroundColor(.white)
                        }
                        .padding(14)
                        .background(DramareelColors.surfaceCard)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(DramareelColors.surfaceBorder, lineWidth: 1))
                        
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
                                .foregroundColor(DramareelColors.primaryPurple)
                                .frame(width: 20)
                            SecureField("Password (min 6 characters)", text: $password)
                                .foregroundColor(.white)
                        }
                        .padding(14)
                        .background(DramareelColors.surfaceCard)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(DramareelColors.surfaceBorder, lineWidth: 1))
                        
                        // Confirm Password
                        HStack(spacing: 12) {
                            Image(systemName: "lock.shield.fill")
                                .foregroundColor(DramareelColors.primaryPurple)
                                .frame(width: 20)
                            SecureField("Confirm Password", text: $confirmPassword)
                                .foregroundColor(.white)
                        }
                        .padding(14)
                        .background(DramareelColors.surfaceCard)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(DramareelColors.surfaceBorder, lineWidth: 1))
                    }
                    .padding(.horizontal, 20)
                    
                    // Register Action Button
                    DramareelButton(
                        title: "Create Account",
                        icon: "sparkles",
                        style: .primaryGradient,
                        isLoading: authService.isLoading,
                        action: handleRegister
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 6)
                    
                    // Terms note
                    Text("By creating an account, you agree to Dramareel's Terms of Service and Privacy Policy.")
                        .font(DramareelTypography.caption(size: 11))
                        .foregroundColor(DramareelColors.textMuted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }
                .padding(.bottom, 30)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Sign Up", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage ?? "An error occurred.")
        }
    }
    
    private func handleRegister() {
        let cleanEmail = email.trimmingCharacters(in: .whitespaces)
        let cleanName = displayName.trimmingCharacters(in: .whitespaces)
        
        guard !cleanEmail.isEmpty, !cleanName.isEmpty else {
            alertMessage = "Please enter your name and email."
            showAlert = true
            return
        }
        
        guard password.count >= 6 else {
            alertMessage = "Password must be at least 6 characters long."
            showAlert = true
            return
        }
        
        guard password == confirmPassword else {
            alertMessage = "Passwords do not match."
            showAlert = true
            return
        }
        
        Task {
            let success = await authService.register(email: cleanEmail, password: password, displayName: cleanName)
            if success {
                dismiss()
            } else if let error = authService.errorMessage {
                alertMessage = error
                showAlert = true
            }
        }
    }
}

public struct ForgotPasswordView: View {
    @ObservedObject var authService: AuthService = .shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var email: String = ""
    @State private var isSubmitting: Bool = false
    @State private var message: String? = nil
    @State private var isSuccess: Bool = false
    
    public init() {}
    
    public var body: some View {
        ZStack {
            DramareelColors.backgroundDark
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(DramareelColors.textMuted)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                Image(systemName: "key.fill")
                    .font(.system(size: 42))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [DramareelColors.neonPink, DramareelColors.electricCyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                VStack(spacing: 6) {
                    Text("Reset Password")
                        .font(DramareelTypography.heroTitle(size: 22))
                        .foregroundColor(DramareelColors.textPrimary)
                    Text("Enter your email address and we'll send you a password reset link.")
                        .font(DramareelTypography.body(size: 13))
                        .foregroundColor(DramareelColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
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
                .padding(.horizontal, 20)
                
                if let message = message {
                    Text(message)
                        .font(DramareelTypography.caption(size: 12))
                        .foregroundColor(isSuccess ? DramareelColors.successGreen : DramareelColors.errorRed)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                DramareelButton(
                    title: "Send Reset Link",
                    icon: "paperplane.fill",
                    style: .primaryGradient,
                    isLoading: isSubmitting,
                    action: handleReset
                )
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
    }
    
    private func handleReset() {
        let cleanEmail = email.trimmingCharacters(in: .whitespaces)
        guard !cleanEmail.isEmpty else {
            message = "Please enter your email."
            isSuccess = false
            return
        }
        
        isSubmitting = true
        Task {
            let result = await authService.forgotPassword(email: cleanEmail)
            isSubmitting = false
            message = result.message
            isSuccess = result.success
        }
    }
}
