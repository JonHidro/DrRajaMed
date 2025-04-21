//
//  SignUpView.swift
//  DrRaja Prototype #3
//
//  Created by Jonathan Hidrogo on 3/23/25.
//

import SwiftUI

struct SignupView: View {
    var onBackToSignIn: (() -> Void)? = nil

    // MARK: – Form state
    @State private var firstName       = ""
    @State private var lastName        = ""
    @State private var email           = ""
    @State private var password        = ""
    @State private var confirmPassword = ""
    @State private var selectedMode: String? = nil

    // MARK: – Alert + sheet state
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showSignInEmailSheet = false

    // MARK: – Environment
    @EnvironmentObject var userSettings: UserSettings
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var navigationManager: NavigationManager

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.6),
                    Color.purple.opacity(0.6)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Form content with dynamic top inset
            GeometryReader { geometry in
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Create Account")
                            .font(.largeTitle).bold()
                            .foregroundColor(.primary)

                        VStack(spacing: 12) {
                            RoundedTextField(placeholder: "First name", text: $firstName)
                            RoundedTextField(placeholder: "Last name",  text: $lastName)
                            RoundedTextField(placeholder: "Email",      text: $email)
                            RoundedTextField(placeholder: "Password",   text: $password, isSecure: true)
                            RoundedTextField(placeholder: "Confirm Password", text: $confirmPassword, isSecure: true)
                        }

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

                        Color.clear.frame(height: 20)
                    }
                    .padding(.horizontal)
                    .padding(.top, geometry.safeAreaInsets.top + -5) // ✅ dynamic spacing
                    .padding(.bottom, 100)
                }
                .scrollDismissesKeyboard(.interactively)
            }

            // Bottom area (NEXT + Sign In)
            VStack {
                Spacer()

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

                Button(action: {
                    showSignInEmailSheet = true
                }) {
                    Text("Already have an account? Sign in")
                        .foregroundColor(.white)
                        .underline()
                }
                .padding(.bottom, 16)
            }

            // Floating back button
            Button(action: {
                onBackToSignIn?()
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                    Text("Back")
                        .font(.system(size: 16))
                }
                .foregroundColor(.white)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.black.opacity(0.2))
                .cornerRadius(10)
                .padding(.leading, 16)
                .padding(.top, 2) // You already adjusted this!
            }
            .zIndex(2)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .alert(alertMessage, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        }
        .sheet(isPresented: $showSignInEmailSheet) {
            SignInEmailView()
                .environmentObject(authManager)
                .environmentObject(navigationManager)
        }
    }

    // MARK: – Validation
    private var isFormFilled: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        !confirmPassword.isEmpty &&
        password == confirmPassword &&
        selectedMode != nil
    }

    // MARK: – Sign-Up Logic
    private func handleNext() {
        guard !firstName.isEmpty else { showError("First name is required."); return }
        guard !lastName.isEmpty else { showError("Last name is required."); return }
        guard !email.isEmpty else { showError("Email is required."); return }
        guard isValidEmail(email) else { showError("Please enter a valid email address."); return }
        guard !password.isEmpty else { showError("Password is required."); return }
        guard !confirmPassword.isEmpty else { showError("Please confirm your password."); return }
        guard password == confirmPassword else { showError("Passwords do not match."); return }
        guard let mode = selectedMode else { showError("Please select either Student or Clinician."); return }

        authManager.signUp(email: email, password: password) { result in
            switch result {
            case .success:
                userSettings.userMode = mode
                userSettings.hasCompletedOnboarding = true
                navigationManager.goToRoot()
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
