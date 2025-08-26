// DONT TOUCH !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//  SignInView.swift
//  DrRaja Prototype #3
//
//  Created by Jonathan Hidrogo on 3/23/25.
//

import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @EnvironmentObject private var authManager:       AuthManager
    @EnvironmentObject private var navigationManager: NavigationManager

    /// Called when “Continue with Email” is tapped
    var onCreateAccount: (() -> Void)? = nil

    var body: some View {
        ZStack {
            // 1) Full-screen looping video background
            LoopingVideoView()
                .ignoresSafeArea()

            // 2) Bottom-anchored sign-in buttons + email + footer
            VStack(spacing: 24) {
                SignInButtons()
                    .environmentObject(authManager)
                    .environmentObject(navigationManager)

                // — Smaller “Continue with Email” button —
                Button(action: {
                    onCreateAccount?()
                }) {
                    Text("Continue with Email")
                        .font(.system(size: 18, weight: .medium))
                        .frame(maxWidth: .infinity, minHeight: 40)    // ↓ height
                        .foregroundColor(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.white, lineWidth: 1)
                        )
                }
                .padding(.horizontal,35)   // ↑ horizontal padding

                Text("By continuing to use DrRajaLabs, you agree to our Terms of Service and Privacy Policy.")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            }
            .padding(.bottom, 50)
            .frame(maxHeight: .infinity, alignment: .bottom)

            // 3) Bottom-anchored FeatureCarousel sitting above the pills
            VStack {
                Spacer()
                FeatureCarousel()
                    .padding(.bottom, 260)   // tweak this if you ever need to shift carousel
            }
            .padding(.horizontal, 30)
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
        // 4) Shift entire overlay group down
        .offset(y: 50)
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView(onCreateAccount: {})
            .environmentObject(AuthManager())
            .environmentObject(NavigationManager())
            .previewDevice("iPhone 14 Pro")
    }
}
