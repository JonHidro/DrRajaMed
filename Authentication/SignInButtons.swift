//
//  SignInButtons.swift
//  DrRaja Prototype #3
//
//  Created by Jonathan Hidrogo on 3/23/25.
//

import SwiftUI
import AuthenticationServices

struct SignInButtons: View {
    @EnvironmentObject private var authManager:       AuthManager
    @EnvironmentObject private var navigationManager: NavigationManager
    @State private var currentNonce: String?

    var body: some View {
        VStack(spacing: 12) {
            // ────────────────────────────────────
            // Google + Apple buttons (original style)
            HStack(spacing: 12) {
                // Google Sign-In Button
                Button(action: signInWithGoogle) {
                    HStack {
                        Image("google_logo")
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text("Google")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .frame(width: 160, height: 44)
                    .background(Color(.systemGray5))
                    .foregroundColor(.primary)
                    .cornerRadius(22)
                }

                // Apple Sign-In Button
                SignInWithAppleButton(
                    .signIn,
                    onRequest: configureAppleSignIn(request:),
                    onCompletion: handleAppleSignIn(result:)
                )
                .frame(width: 160, height: 44)
                .cornerRadius(22)
            }

            // ────────────────────────────────────
            // White divider + “Or”
            HStack(spacing: 8) {
                Rectangle()
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)

                Text("Or")
                    .font(.footnote)
                    .foregroundColor(.white)

                Rectangle()
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 30)
    }

    // MARK: – Google Sign-In
    private func signInWithGoogle() {
        guard
            let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let root = scene.windows.first?.rootViewController
        else { return }
        authManager.signInWithGoogle(presentingViewController: root)
    }

    // MARK: – Apple Request Configuration
    private func configureAppleSignIn(request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonceString()
        currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
    }

    // MARK: – Apple Completion Handler
    private func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
        guard let nonce = currentNonce else { return }
        authManager.handleAppleSignIn(result, nonce: nonce)
        navigationManager.goToRoot()
    }
}
