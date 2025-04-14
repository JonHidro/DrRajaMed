//
//  SignInEmailView.swift
//  DrRajaMed
//
//  Created by Jonathan Hidrogo on 4/12/25.
//

import SwiftUI

struct SignInEmailView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showForgotPasswordSheet = false
    
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var navigationManager: NavigationManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.6),
                    Color.purple.opacity(0.6)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Welcome Back")
                    .font(.largeTitle).bold()
                    .foregroundColor(.primary)
                    .padding(.top, 40)
                
                VStack(spacing: 16) {
                    RoundedTextField(placeholder: "Email", text: $email)
                    RoundedTextField(placeholder: "Password", text: $password, isSecure: true)
                }
                .padding(.horizontal)
                
                Button(action: handleSignIn) {
                    Text("SIGN IN")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background((!email.isEmpty && !password.isEmpty && isValidEmail(email)) ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                }
                .disabled(email.isEmpty || password.isEmpty || !isValidEmail(email))
                
                Button("Forgot Password?") {
                    showForgotPasswordSheet = true
                }
                .foregroundColor(.white)
                .padding(.top, 8)
                
                Spacer()
            }
            .padding(.bottom, 40)
        }
        .alert(alertMessage, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        }
        .sheet(isPresented: $showForgotPasswordSheet) {
            ForgotPasswordView()
                .environmentObject(authManager)
        }
    }
    
    private func handleSignIn() {
        // Adding a trim to prevent whitespace-related login issues
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        authManager.signIn(email: trimmedEmail, password: password) { result in
            switch result {
            case .success:
                navigationManager.goToRoot() // Navigate to HomeViewContent
                dismiss() // Dismiss this sheet
            case .failure(let error):
                alertMessage = error.localizedDescription
                showAlert = true
            }
        }
    }
    
    private func isValidEmail(_ s: String) -> Bool {
        let pattern = #"^\S+@\S+\.\S+$"#
        return s.range(of: pattern, options: .regularExpression) != nil
    }
}
