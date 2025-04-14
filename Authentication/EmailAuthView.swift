//
//  EmailAuthView.swift
//  DrRajaMed
//
//  Created by Jonathan Hidrogo on 4/11/25.
//

import SwiftUI

struct SignUpView: View {
    // MARK: – Define authentication types.
    enum AuthType: String, CaseIterable, Identifiable {
        case signIn = "Sign In"
        case signUp = "Sign Up"
        var id: String { self.rawValue }
    }
    
    // MARK: – State variables for mode and form fields.
    @State private var authType: AuthType = .signUp
    
    // Common fields
    @State private var email    = ""
    @State private var password = ""
    
    // Extra fields for Sign Up mode
    @State private var firstName       = ""
    @State private var lastName        = ""
    @State private var confirmPassword = ""
    @State private var selectedMode: String? = nil
    @State private var isAgreementAccepted  = false

    // MARK: – Alert state
    @State private var showAlert    = false
    @State private var alertMessage = ""
    
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
                
                // 3) Scrollable form content.
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Title changes based on mode.
                        if authType == .signUp {
                            Text("Create Account")
                                .font(.largeTitle).bold()
                                .foregroundColor(.primary)
                        } else {
                            Text("Welcome Back")
                                .font(.largeTitle).bold()
                                .foregroundColor(.primary)
                        }
                        
                        // For Sign Up, show additional name fields.
                        if authType == .signUp {
                            RoundedTextField(placeholder: "First name", text: $firstName)
                            RoundedTextField(placeholder: "Last name",  text: $lastName)
                        }
                        
                        // Common fields: email and password.
                        RoundedTextField(placeholder: "Email", text: $email)
                        RoundedTextField(placeholder: "Password", text: $password, isSecure: true)
                        
                        // Additional fields only for Sign Up.
                        if authType == .signUp {
                            RoundedTextField(placeholder: "Confirm Password", text: $confirmPassword, isSecure: true)
                            
                            // Mode selector.
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
                            
                            // Liability & legal agreement.
                            Toggle(isOn: $isAgreementAccepted) {
                                Text("I accept the **Liability Notice, Legal Notice, Terms and Conditions, and Privacy Policy**.")
                                    .font(.footnote)
                                    .foregroundColor(.primary.opacity(0.7))
                            }
                            .toggleStyle(SwitchToggleStyle(tint: .blue))
                        }
                        
                        // Spacer so content scrolls above the button.
                        Color.clear.frame(height: 20)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .padding(.bottom, 100) // leave room for the pinned button
                }
                .scrollDismissesKeyboard(.interactively)
                
                // 4) Pinned authentication button.
                VStack {
                    Button(action: handleAction) {
                        Text(authType == .signUp ? "SIGN UP" : "SIGN IN")
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
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .alert(alertMessage, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        }
    }
    
    // MARK: – Validation: Different rules for Sign In and Sign Up.
    private var isFormValid: Bool {
        if authType == .signUp {
            return !firstName.isEmpty &&
                   !lastName.isEmpty &&
                   !email.isEmpty &&
                   isValidEmail(email) &&
                   !password.isEmpty &&
                   !confirmPassword.isEmpty &&
                   password == confirmPassword &&
                   selectedMode != nil &&
                   isAgreementAccepted
        } else { // Sign In validation.
            return !email.isEmpty &&
                   isValidEmail(email) &&
                   !password.isEmpty
        }
    }
    
    // MARK: – Handle the selected action.
    private func handleAction() {
        if authType == .signUp {
            handleSignUp()
        } else {
            handleSignIn()
        }
    }
    
    private func handleSignUp() {
        // Local validations are already performed via isFormValid.
        authManager.signUp(email: email, password: password) { result in
            switch result {
            case .success:
                if let mode = selectedMode {
                    userSettings.userMode = mode
                }
                userSettings.hasCompletedOnboarding = true
                navigationManager.goToRoot()
                dismiss()
            case .failure(let err):
                showError(err.localizedDescription)
            }
        }
    }
    
    private func handleSignIn() {
        authManager.signIn(email: email, password: password) { result in
            switch result {
            case .success:
                navigationManager.goToRoot()
                dismiss()
            case .failure(let err):
                showError(err.localizedDescription)
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

// MARK: – Reusable subviews.

struct RoundedTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false

    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(
                        placeholder.lowercased().contains("email")
                        ? .emailAddress : .default
                    )
                    .autocapitalization(.none)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .foregroundColor(.primary)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct OptionButton: View {
    let title: String
    let description: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline).bold()
                        .foregroundColor(.primary)
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.primary.opacity(0.8))
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(
                isSelected ?
                    Color(UIColor.tertiarySystemFill) :
                    Color(UIColor.secondarySystemFill)
            )
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: – Preview

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
            .environmentObject(UserSettings())
            .environmentObject(AuthManager())
            .environmentObject(NavigationManager())
            .previewDevice("iPhone 14 Pro")
        // Tap the ▶️ Live Preview button in the canvas to interact with fields
    }
}
