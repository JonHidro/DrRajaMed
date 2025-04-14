//
//  ForgotPasswordView.swift
//  DrRajaMed
//
//  Created by Jonathan Hidrogo on 4/13/25.
//

import SwiftUI

struct ForgotPasswordView: View {
    @State private var email = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isSuccess = false
    
    @EnvironmentObject var authManager: AuthManager
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
                Text("Reset Password")
                    .font(.largeTitle).bold()
                    .foregroundColor(.primary)
                    .padding(.top, 40)
                
                Text("Enter your email address and we'll send you a link to reset your password.")
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                RoundedTextField(placeholder: "Email", text: $email)
                    .padding(.horizontal)
                
                Button(action: handlePasswordReset) {
                    Text("SEND RESET LINK")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(!email.isEmpty && isValidEmail(email) ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                }
                .disabled(email.isEmpty || !isValidEmail(email))
                
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.white)
                .padding(.top, 8)
                
                Spacer()
            }
            .padding(.horizontal)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(isSuccess ? "Success" : "Error"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    if isSuccess {
                        dismiss()
                    }
                }
            )
        }
    }
    
    private func handlePasswordReset() {
        authManager.resetPassword(email: email) { result in
            switch result {
            case .success:
                isSuccess = true
                alertMessage = "Password reset link has been sent to your email."
                showAlert = true
            case .failure(let error):
                isSuccess = false
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
