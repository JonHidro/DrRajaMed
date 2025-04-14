//
//  AuthManager.swift
//  DrRaja Prototype #3
//
//  Created by Jonathan Hidrogo on 3/23/25.
//

import SwiftUI
import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn
import AuthenticationServices

class AuthManager: ObservableObject {
    // MARK: – Published state
    @Published var isSignedIn: Bool = false
    @Published var currentUser: User?

    // MARK: – Internal listener handle (not private so previews can remove it)
    var handle: AuthStateDidChangeListenerHandle?

    // MARK: – Init & deinit
    init() {
        // Listen to Firebase auth state changes
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUser = user
                self?.isSignedIn   = (user != nil)
                if let email = user?.email {
                    print("✅ Auth state changed: signed in as \(email)")
                } else {
                    print("🚫 Auth state changed: signed out")
                }
            }
        }
    }

    deinit {
        // Remove listener
        if let h = handle {
            Auth.auth().removeStateDidChangeListener(h)
        }
    }

    // MARK: – Email/Password Sign‑Up
    func signUp(
        email: String,
        password: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        Auth.auth().createUser(withEmail: email, password: password) { _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    // MARK: – Email/Password Sign‑In
    func signIn(
        email: String,
        password: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    // MARK: – Google Sign‑In
    func signInWithGoogle(presentingViewController: UIViewController) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("Error: Missing Firebase clientID")
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { result, error in
            if let error = error {
                print("Google Sign‑In Error:", error.localizedDescription)
                return
            }
            guard
                let user = result?.user,
                let idToken = user.idToken?.tokenString
            else {
                print("Google Sign‑In: Missing user or ID token")
                return
            }

            let accessToken = user.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: accessToken
            )

            Auth.auth().signIn(with: credential) { _, error in
                if let error = error {
                    print("Firebase Google Auth Error:", error.localizedDescription)
                } else {
                    // AuthState listener will pick this up
                    print("✅ Signed in with Google")
                }
            }
        }
    }

    // MARK: – Apple Sign‑In
    /// Call this from your SignInButtons onCompletion
    func handleAppleSignIn(
        _ result: Result<ASAuthorization, Error>,
        nonce: String?
    ) {
        switch result {
        case .success(let auth):
            guard
                let cred = auth.credential as? ASAuthorizationAppleIDCredential,
                let tokenData = cred.identityToken,
                let tokenString = String(data: tokenData, encoding: .utf8),
                let nonce = nonce
            else {
                print("Apple Sign‑In: Missing credentials or nonce.")
                return
            }

            let credential = OAuthProvider.credential(
                providerID: .apple,
                idToken:    tokenString,
                rawNonce:   nonce
            )

            Auth.auth().signIn(with: credential) { _, error in
                if let error = error {
                    print("Firebase Apple Auth Error:", error.localizedDescription)
                } else {
                    // AuthState listener will pick this up
                    print("✅ Signed in with Apple")
                }
            }

        case .failure(let error):
            print("Apple Sign‑In Failed:", error.localizedDescription)
        }
    }

    // MARK: – Sign Out
    func signOut() {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            DispatchQueue.main.async {
                self.isSignedIn   = false
                self.currentUser = nil
            }
            print("👋 Signed out")
        } catch {
            print("Sign‑out failed:", error.localizedDescription)
        }
    }
    
    // MARK: - Password Reset
    func resetPassword(
        email: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    // MARK: – Preview Helper
    /// A version of AuthManager for SwiftUI previews that
    /// bypasses Firebase and forces a signed‑in state.
    static var preview: AuthManager {
        let m = AuthManager()
        // Remove the real Firebase listener
        if let h = m.handle {
            Auth.auth().removeStateDidChangeListener(h)
            m.handle = nil
        }
        // Force signed‑in
        m.isSignedIn = true
        return m
    }
}
