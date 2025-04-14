//
//  SignUpView.swift
//  DrRaja Prototype #3
//
//  Created by Jonathan Hidrogo on 3/23/25.
//

import SwiftUI

struct SignupView: View {
    // MARK: – Form state
    @State private var firstName       = ""
    @State private var lastName        = ""
    @State private var email           = ""
    @State private var password        = ""
    @State private var confirmPassword = ""
    @State private var selectedMode: String? = nil
    // Liability toggle removed

    // MARK: – Alert state
    @State private var showAlert    = false
    @State private var alertMessage = ""

    // MARK: – For presenting the SignIn sheet
    @State private var showSignInSheet = false

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

            // 2) Scrollable form
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Create Account")
                        .font(.largeTitle).bold()
                        .foregroundColor(.primary)

                    // Fields for sign up:
                    VStack(spacing: 12) {
                        RoundedTextField(placeholder: "First name", text: $firstName)
                        RoundedTextField(placeholder: "Last name",  text: $lastName)
                        RoundedTextField(placeholder: "Email",      text: $email)
                        RoundedTextField(placeholder: "Password",   text: $password, isSecure: true)
                        RoundedTextField(placeholder: "Confirm Password", text: $confirmPassword, isSecure: true)
                    }

                    // Mode selector
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

                    // Spacer so content scrolls above the pinned button
                    Color.clear.frame(height: 20)
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 100) // leave room for the pinned button area
            }
            .scrollDismissesKeyboard(.interactively)

            // 3) Pinned bottom area with NEXT button and Sign in link
            VStack {
                Spacer()
                // NEXT button for sign up action
                Button(action: handleNext) {
                    Text("NEXT")
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(isFormFilled ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                }
                .disabled(!isFormFilled)
                .padding(.top, 8)

                // Sign in toggle button
                Button(action: { showSignInSheet = true }) {
                    Text("Already have an account? Sign in")
                        .foregroundColor(.white)
                        .underline()
                }
                .padding(.bottom, 16)
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .alert(alertMessage, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        }
        // Present the dedicated SignInEmailView as a sheet.
        .sheet(isPresented: $showSignInSheet) {
            SignInEmailView()
                .environmentObject(authManager)
                .environmentObject(navigationManager)
        }
    }
    
    // MARK: – Validation for Sign Up
    private var isFormFilled: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        !confirmPassword.isEmpty &&
        password == confirmPassword &&
        selectedMode != nil
    }
    
    // MARK: – Handle the Sign Up action
    private func handleNext() {
        // Local validation checks
        guard !firstName.isEmpty else {
            showError("First name is required."); return
        }
        guard !lastName.isEmpty else {
            showError("Last name is required."); return
        }
        guard !email.isEmpty else {
            showError("Email is required."); return
        }
        guard isValidEmail(email) else {
            showError("Please enter a valid email address."); return
        }
        guard !password.isEmpty else {
            showError("Password is required."); return
        }
        guard !confirmPassword.isEmpty else {
            showError("Please confirm your password."); return
        }
        guard password == confirmPassword else {
            showError("Passwords do not match."); return
        }
        guard let mode = selectedMode else {
            showError("Please select either Student or Clinician."); return
        }
        
        // Firebase sign‑up
        authManager.signUp(email: email, password: password) { result in
            switch result {
            case .success:
                userSettings.userMode = mode
                userSettings.hasCompletedOnboarding = true
                navigationManager.goToRoot()   // Navigate to HomeViewContent
                dismiss()                      // Dismiss the sign-up view
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

// MARK: – Reusable subviews

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
                        placeholder.lowercased().contains("email") ? .emailAddress : .default
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
                isSelected ? Color(UIColor.tertiarySystemFill)
                           : Color(UIColor.secondarySystemFill)
            )
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: – Preview

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView()
            .environmentObject(UserSettings())
            .environmentObject(AuthManager())
            .environmentObject(NavigationManager())
            .previewDevice("iPhone 14 Pro")
    }
}
