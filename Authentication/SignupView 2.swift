//
//  SignupView 2.swift
//  DrRajaMed
//
//  Created by Jonathan Hidrogo on 4/12/25.
//


import SwiftUI

struct SignupView: View {
    // MARK: – Define authentication types.
    enum AuthType: String, CaseIterable, Identifiable {
        case signIn = "Sign In"
        case signUp = "Sign Up"
        var id: String { self.rawValue }
    }
    
    // MARK: – State variables for mode and form fields.
    @State private var authType: AuthType = .signUp
    
    // Common fields (we will only use these for sign‑up)
    @State private var email    = ""
    @State private var password = ""
    
    // Extra fields for Sign Up mode
    @State private var firstName       = ""
    @State private var lastName        = ""
    @State private var confirmPassword = ""
    @State private var selectedMode: String? = nil
    @State private var isAgreementAccepted = false

    // MARK: – Alert state
    @State private var showAlert    = false
    @State private var alertMessage = ""
    
    // For presenting the dedicated sign‑in view
    @State private var showSignInEmailView = false
    
    // MARK: – Environment
    @EnvironmentObject var userSettings: UserSettings
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var navigationManager: NavigationManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // 1) Full-screen gradient background.
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.6),
                    Color.purple.opacity(0.6)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                // 2) Picker to toggle between Sign In and Sign Up.
                Picker("Authentication", selection: $authType) {
                    ForEach(AuthType.allCases) { type in
                        Text(type.rawValue)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // 3) Form content changes based on mode.
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if authType == .signUp {
                            Text("Create Account")
                                .font(.largeTitle).bold()
                                .foregroundColor(.primary)
                            
                            // Sign-Up fields
                            RoundedTextField(placeholder: "First name", text: $firstName)
                            RoundedTextField(placeholder: "Last name", text: $lastName)
                            RoundedTextField(placeholder: "Email", text: $email)
                            RoundedTextField(placeholder: "Password", text: $password, isSecure: true)
                            RoundedTextField(placeholder: "Confirm Password", text: $confirmPassword, isSecure: true)
                            
                            Text("Select your mode")
                                .font(.headline).bold()
                                .foregroundColor(.primary)
                            VStack(spacing: 10) {
                                OptionButton(
                                    title: "Student",
                                    description: "Educational‑focused content and exam materials.",
                                    isSelected: selectedMode == "Student"
                                ) { selectedMode = "Student" }
                                
                                OptionButton(
                                    title: "Clinician",
                                    description: "Clinical‑focused content including dosages and guidelines.",
                                    isSelected: selectedMode == "Clinician"
                                ) { selectedMode = "Clinician" }
                            }
                            
                            // The liability notice is removed from here,
                            // as it is now provided in the SignInView.
                        }
                        else {
                            // For sign-in mode, just show a message and a button
                            // that presents our dedicated SignInEmailView.
                            Text("Welcome Back")
                                .font(.largeTitle).bold()
                                .foregroundColor(.primary)
                            
                            Text("Already have an account? Tap below to sign in.")
                                .font(.subheadline)
                                .foregroundColor(.primary.opacity(0.8))
                                .padding(.bottom, 20)
                            
                            Button(action: { showSignInEmailView = true }) {
                                Text("Continue to Sign In")
                                    .frame(maxWidth: .infinity, minHeight: 50)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .padding(.horizontal, 16)
                            }
                        }
                        
                        // Spacer so content scrolls above the pinned button (if needed)
                        Color.clear.frame(height: 20)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .padding(.bottom, 100)
                }
                .scrollDismissesKeyboard(.interactively)
                
                // 4) Pinned authentication button for sign-up.
                if authType == .signUp {
                    VStack {
                        Button(action: handleSignUp) {
                            Text("SIGN UP")
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .background(isFormValid ? Color.blue : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(.horizontal, 16)
                        }
                        .disabled(!isFormValid)
                        .padding(.bottom, 16)
                    }
                }
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .alert(alertMessage, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        }
        // Present the dedicated SignInEmailView when needed.
        .sheet(isPresented: $showSignInEmailView) {
            SignInEmailView()
                .environmentObject(authManager)
                .environmentObject(navigationManager)
        }
    }
    
    // MARK: – Validation for Sign Up.
    private var isFormValid: Bool {
        return !firstName.isEmpty &&
               !lastName.isEmpty &&
               !email.isEmpty &&
               isValidEmail(email) &&
               !password.isEmpty &&
               !confirmPassword.isEmpty &&
               (password == confirmPassword) &&
               selectedMode != nil &&
               isAgreementAccepted
    }
    
    // MARK: – Handle the Sign Up action.
    private func handleSignUp() {
        authManager.signUp(email: email, password: password) { result in
            switch result {
            case .success:
                if let mode = selectedMode {
                    userSettings.userMode = mode
                }
                userSettings.hasCompletedOnboarding = true
                navigationManager.goToRoot()
                dismiss()
            case .failure(let error):
                showError(error.localizedDescription)
            }
        }
    }
    
    private func showError(_ msg: String) {
        alertMessage = msg
        showAlert = true
    }
    
    private func isValidEmail(_ s: String) -> Bool {
        let pattern = #"^\S+@\S+\.\S+$"#
        return s.range(of: pattern, options: .regularExpression) != nil
    }
}
