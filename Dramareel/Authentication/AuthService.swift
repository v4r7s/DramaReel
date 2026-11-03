import Foundation
import SwiftUI
import FirebaseAuth

@MainActor
public final class AuthService: ObservableObject {
    public static let shared = AuthService()
    
    @Published public var currentUser: UserProfile?
    @Published public var isAuthenticated: Bool = false
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil
    
    private let apiClient: APIClient
    private let keychain: KeychainManager
    private let localStorage: LocalStorageManager
    
    public init(
        apiClient: APIClient = .shared,
        keychain: KeychainManager = .shared,
        localStorage: LocalStorageManager = .shared
    ) {
        self.apiClient = apiClient
        self.keychain = keychain
        self.localStorage = localStorage
        
        // Restore session if token exists
        Task {
            await checkExistingSession()
        }
    }
    
    // MARK: - Session Check
    public func checkExistingSession() async {
        guard let uid = keychain.get(key: AppConstants.KeychainKeys.userUid), !uid.isEmpty else {
            self.isAuthenticated = false
            return
        }
        
        // Refresh token from Firebase Auth if current user is logged in
        if let firebaseUser = Auth.auth().currentUser {
            do {
                let token = try await firebaseUser.getIDToken()
                keychain.save(key: AppConstants.KeychainKeys.firebaseIdToken, value: token)
                await fetchUserProfile(uid: uid)
                self.isAuthenticated = true
            } catch {
                #if DEBUG
                print("Failed to refresh Firebase token: \(error.localizedDescription)")
                #endif
                self.isAuthenticated = false
            }
        }
    }
    
    // MARK: - Email Sign In
    public func signIn(email: String, password: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
            let token = try await authResult.user.getIDToken()
            let uid = authResult.user.uid
            
            keychain.save(key: AppConstants.KeychainKeys.firebaseIdToken, value: token)
            keychain.save(key: AppConstants.KeychainKeys.userUid, value: uid)
            keychain.save(key: AppConstants.KeychainKeys.userEmail, value: email)
            
            await syncProfileWithBackend(uid: uid, email: email, displayName: authResult.user.displayName, photoURL: authResult.user.photoURL?.absoluteString)
            self.isAuthenticated = true
            return true
        } catch {
            self.errorMessage = error.localizedDescription
            return false
        }
    }
    
    // MARK: - Email Registration
    public func register(email: String, password: String, displayName: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            
            // Set display name on Firebase
            let changeRequest = authResult.user.createProfileChangeRequest()
            changeRequest.displayName = displayName
            try? await changeRequest.commitChanges()
            
            let token = try await authResult.user.getIDToken()
            let uid = authResult.user.uid
            
            keychain.save(key: AppConstants.KeychainKeys.firebaseIdToken, value: token)
            keychain.save(key: AppConstants.KeychainKeys.userUid, value: uid)
            keychain.save(key: AppConstants.KeychainKeys.userEmail, value: email)
            
            // Provision user on MongoDB backend
            await syncProfileWithBackend(uid: uid, email: email, displayName: displayName, photoURL: nil)
            self.isAuthenticated = true
            return true
        } catch {
            self.errorMessage = error.localizedDescription
            return false
        }
    }
    
    // MARK: - Sign in with Apple
    public func signInWithApple() async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        return await withCheckedContinuation { continuation in
            AppleSignInCoordinator.shared.startAppleSignIn { [weak self] result in
                guard let self = self else {
                    continuation.resume(returning: false)
                    return
                }
                
                Task { @MainActor in
                    switch result {
                    case .success(let credentials):
                        do {
                            let oauthCredential = OAuthProvider.appleCredential(
                                withIDToken: credentials.idToken,
                                rawNonce: credentials.rawNonce,
                                fullName: nil
                            )
                            let authResult = try await Auth.auth().signIn(with: oauthCredential)
                            let token = try await authResult.user.getIDToken()
                            let uid = authResult.user.uid
                            let email = credentials.email ?? authResult.user.email
                            let name = credentials.fullName ?? authResult.user.displayName
                            
                            self.keychain.save(key: AppConstants.KeychainKeys.firebaseIdToken, value: token)
                            self.keychain.save(key: AppConstants.KeychainKeys.userUid, value: uid)
                            if let email = email {
                                self.keychain.save(key: AppConstants.KeychainKeys.userEmail, value: email)
                            }
                            
                            await self.syncProfileWithBackend(uid: uid, email: email, displayName: name, photoURL: nil)
                            self.isAuthenticated = true
                            continuation.resume(returning: true)
                        } catch {
                            self.errorMessage = error.localizedDescription
                            continuation.resume(returning: false)
                        }
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                        continuation.resume(returning: false)
                    }
                }
            }
        }
    }
    
    // MARK: - Forgot Password
    public func forgotPassword(email: String) async -> (success: Bool, message: String) {
        do {
            let data = try await apiClient.requestRaw(.forgotPassword(email: email))
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let success = json["success"] as? Bool {
                let msg = json["message"] as? String ?? "Password reset email sent."
                return (success, msg)
            }
            return (true, "Password reset email sent.")
        } catch {
            return (false, error.localizedDescription)
        }
    }
    
    // MARK: - Profile Sync & Retrieval
    public func fetchUserProfile(uid: String) async {
        do {
            let profile: UserProfile = try await apiClient.request(.getUser(uid: uid))
            self.currentUser = profile
            // Sync unlocked IDs to local storage
            localStorage.setUnlockedEpisodeIds(Set(profile.unlockedEpisodeIds))
        } catch {
            #if DEBUG
            print("Failed to fetch user profile: \(error.localizedDescription)")
            #endif
        }
    }
    
    private func syncProfileWithBackend(uid: String, email: String?, displayName: String?, photoURL: String?) async {
        // Try to fetch profile from MongoDB
        do {
            let profile: UserProfile = try await apiClient.request(.getUser(uid: uid))
            self.currentUser = profile
            self.localStorage.setUnlockedEpisodeIds(Set(profile.unlockedEpisodeIds))
        } catch {
            // User does not exist in MongoDB yet, provision new account
            do {
                let newProfile: UserProfile = try await apiClient.request(.createUser(uid: uid, email: email, displayName: displayName, photoURL: photoURL))
                self.currentUser = newProfile
            } catch {
                #if DEBUG
                print("Failed to provision profile: \(error)")
                #endif
            }
        }
    }
    
    // MARK: - Delete Account
    public func deleteAccount() async -> (success: Bool, message: String) {
        guard let uid = currentUser?.uid else { return (false, "Not signed in.") }
        isLoading = true
        defer { isLoading = false }
        
        do {
            _ = try await apiClient.requestRaw(.deleteUser(uid: uid))
            try? await Auth.auth().currentUser?.delete()
            signOut()
            return (true, "Account permanently deleted.")
        } catch {
            return (false, error.localizedDescription)
        }
    }
    
    // MARK: - Sign Out
    public func signOut() {
        try? Auth.auth().signOut()
        keychain.clearAll()
        localStorage.clearUserData()
        self.currentUser = nil
        self.isAuthenticated = false
    }
}
