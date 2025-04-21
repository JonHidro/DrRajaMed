//
//  AuthGateView.swift
//  DrRajaMed
//
//  Created by Jonathan Hidrogo on 4/20/25.
//

import SwiftUI

struct AuthGateView: View {
    @State private var isCreatingAccount = false

    var body: some View {
        ZStack {
            if isCreatingAccount {
                SignupView(onBackToSignIn: {
                    isCreatingAccount = false
                })
            } else {
                SignInView(onCreateAccount: {
                    isCreatingAccount = true
                })
            }
        }
    }
}
