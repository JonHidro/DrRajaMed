//
//  SignUpView.swift
//  DrRaja Prototype #3
//
//  Created by Jonathan Hidrogo on 3/23/25.
//

import SwiftUI

struct SignupView: View {
    // Callback to go back to Sign In
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
        GeometryReader { geo in
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

                // Main content
                VStack(alignment: .leading, spacing: 20) {
                    // ← Back chevron + title
                    HStack(spacing: 12) {
                        Button(action: { onBackToSignIn?() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.primary)
                        }

                        Text("Create Account")
                            .font(.largeTitle).bold()
                            .foregroundColor(.primary)

                        Spacer()
                    }

                    // ← Form fields
                    VStack(spacing: 12) {
                        RoundedTextField(placeholder: "First name",       text: $firstName)
                        RoundedTextField(placeholder: "Last name",        text: $lastName)
                        RoundedTextField(placeholder: "Email",            text: $email)
                        RoundedTextField(placeholder: "Password",         text: $password,       isSecure: true)
                        RoundedTextField(placeholder: "Confirm Password", text: $confirmPassword, isSecure: true)
                    }

                    // ← Mode selection header
                    Text("Select your mode")
                        .font(.headline).bold()
                        .foregroundColor(.primary)

                    // ← Mode buttons
                    VStack(spacing: 10) {
                        OptionButton(
                            title: "Student",
                            description: "Educational-focused content and exam materials.",
                            isSelected: selectedMode == "Student"
                        ) {
                            withAnimation { selectedMode = "Student" }
                        }

                        OptionButton(
                            title: "Clinician",
                            description: "Clinical-focused content including dosages and guidelines.",
                            isSelected: selectedMode == "Clinician"
                        ) {
                            withAnimation { selectedMode = "Clinician" }
                        }
                    }

                    // ← Bottom action buttons
                    VStack(spacing: 8) {
                        Button(action: handleNext) {
                            Text("NEXT")
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .background(isFormFilled ? Color.blue : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .disabled(!isFormFilled)

                        Button(action: { showSignInEmailSheet = true }) {
                            Text("Already have an account? Sign in")
                                .underline()
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal, 16)
                // push content below notch
                .padding(.top, geo.safeAreaInsets.top + 8)
                // clear just enough at bottom for home-indicator
                .padding(.bottom, geo.safeAreaInsets.bottom + 8)
                // hug to the top of screen
                .frame(maxHeight: .infinity, alignment: .top)
                // **lift everything up** by 20 points
                .offset(y: -20)
            }
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

// MARK: – Reusable Subviews

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
                            ? .emailAddress
                            : .default
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
                        .lineLimit(isSelected ? nil : 2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, isSelected ? 16 : 10)
            .background(
                isSelected
                    ? Color(UIColor.tertiarySystemFill)
                    : Color(UIColor.secondarySystemFill)
            )
            .cornerRadius(10)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
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
