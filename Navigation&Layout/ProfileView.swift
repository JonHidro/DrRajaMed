//
//  ProfileView.swift
//  DrRaja Prototype #3
//
//  Created by Jonathan Hidrogo on 3/23/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var themeManager: ThemeManager  // 👈 Use global theme state
    
    // Sample user data
    @State private var username: String = "Username"
    @State private var email: String = "user@example.com"
    @State private var notificationsEnabled: Bool = true

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // MARK: - Header
                ZStack(alignment: .bottomLeading) {
                    RadialGradient(
                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                        center: .topLeading,
                        startRadius: 50,
                        endRadius: 400
                    )
                    .ignoresSafeArea(edges: .top)
                    .frame(height: 100)

                    Text("Profile")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.leading, 16)
                        .padding(.bottom, 1)
                }

                // MARK: - User Info
                VStack(alignment: .center, spacing: 12) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                        .padding(.top, 20)

                    Text(username)
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text(email)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 10)

                    Button("Edit Profile") {
                        // Edit profile logic
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(20)
                    .padding(.bottom, 20)
                }
                .padding(.horizontal)

                // MARK: - Settings
                VStack(alignment: .leading, spacing: 0) {
                    Text("Settings")
                        .font(.headline)
                        .padding(.horizontal)
                        .padding(.top, 16)
                        .padding(.bottom, 8)

                    // Dark Mode Toggle
                    HStack {
                        Label("Dark Mode", systemImage: "moon.fill")
                        Spacer()
                        Toggle("", isOn: $themeManager.isDarkMode) // 🔥 Global theme toggle
                            .tint(.green)
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)

                    // Notifications Toggle
                    HStack {
                        Label("Notifications", systemImage: "bell.fill")
                        Spacer()
                        Toggle("", isOn: $notificationsEnabled)
                            .tint(.green)
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.top, 8)

                    // Policy Links
                    ForEach(policyButtons, id: \.title) { button in
                        Button(action: button.action) {
                            HStack {
                                Label(button.title, systemImage: button.icon)
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(10)
                            .foregroundColor(.primary)
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                }
                .padding(.bottom, 20)

                // MARK: - Sign Out Button
                Button(action: {
                    authManager.signOut()
                    navigationManager.goToRoot()
                }) {
                    Text("Sign Out")
                        .font(.headline)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom, 25)
            }
        }
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.top)
    }

    // MARK: – Reusable policy buttons
    var policyButtons: [(title: String, icon: String, action: () -> Void)] {
        [
            ("Privacy Policy", "shield.fill", {}),
            ("Terms of Service", "doc.text.fill", {}),
            ("About", "info.circle.fill", {})
        ]
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProfileView()
        }
        .environmentObject(AuthManager.preview)
        .environmentObject(NavigationManager())
        .environmentObject(ThemeManager())
        .previewDevice("iPhone 14 Pro")
    }
}
