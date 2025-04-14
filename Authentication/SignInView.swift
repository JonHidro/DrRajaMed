// DONT TOUCH !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//  SignInView.swift
//  DrRaja Prototype #3
//
//  Created by Jonathan Hidrogo on 3/23/25.
//

import SwiftUI

struct SignInView: View {
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        NavigationStack {
            ZStack {
                LoopingVideoView()
                    .ignoresSafeArea()

                VStack {
                    Spacer()

                    FeatureCarousel()
                        .offset(y: 90)

                    Spacer()

                    SignInButtons()
                        .environmentObject(authManager)

                    // ← now points to SignUpView()
                    NavigationLink(destination: SignupView()) {
                        Text("Sign Up with Email")
                            .font(.system(size: 18, weight: .medium))
                            .frame(maxWidth: .infinity, minHeight: 40)
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.white, lineWidth: 1)
                            )
                            .padding(.horizontal, 30)
                    }
                    .padding(.top, 20)

                    Text("By signing up, you agree to Terms of Use")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }
                .padding(.bottom, 50)
            }
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
            .environmentObject(AuthManager())
            .environmentObject(UserSettings())
            .environmentObject(NavigationManager())
            .previewDevice("iPhone 14 Pro")
    }
}

