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
    @EnvironmentObject var themeManager: ThemeManager

    @State private var notificationsEnabled: Bool = true
    @State private var isEditingName = false
    @State private var newName = ""
    @State private var refreshID = UUID()

    @State private var showPrivacyPolicy = false
    @State private var showTerms = false
    @State private var showAbout = false

    var username: String {
        authManager.displayName.isEmpty ? "Username" : authManager.displayName
    }

    var userEmail: String {
        authManager.currentUser?.email ?? "Not signed in"
    }

    var body: some View {
        ScrollView(showsIndicators: true) {
            VStack(spacing: 0) {
                // MARK: – Header
                ZStack(alignment: .bottomLeading) {
                    RadialGradient(
                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                        center: .topLeading,
                        startRadius: 50,
                        endRadius: 400
                    )
                    .ignoresSafeArea(edges: .top)
                    .frame(height: 100)

                    HStack {
                        Spacer()
                        Button(action: {
                            themeManager.isDarkMode.toggle()
                        }) {
                            Image(systemName: themeManager.isDarkMode ? "sun.max.fill" : "moon.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.white)
                                .padding(.top, 40)
                                .padding(.trailing, 16)
                        }
                    }

                    Text("Profile")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.leading, 16)
                        .padding(.bottom, 1)
                }

                // MARK: – Profile Info
                VStack(alignment: .center, spacing: 12) {
                    ProfileImageView()

                    Text(username)
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text(userEmail)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 10)

                    Button("Edit Profile") {
                        newName = username
                        isEditingName = true
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(20)
                    .padding(.bottom, 20)
                }
                .padding(.top, 32) // 👈 Adds space from header
                .padding(.horizontal)
                .id(refreshID)

                // MARK: – Settings Section
                VStack(alignment: .leading, spacing: 0) {
                    Text("Settings")
                        .font(.headline)
                        .padding(.horizontal)
                        .padding(.top, 16)
                        .padding(.bottom, 8)

                    settingToggle(label: "Notifications", systemImage: "bell.fill", isOn: $notificationsEnabled)

                    Button(action: { showPrivacyPolicy = true }) {
                        policyRow(title: "Privacy Policy", icon: "shield.fill")
                    }
                    Button(action: { showTerms = true }) {
                        policyRow(title: "Terms of Service", icon: "doc.text.fill")
                    }
                    Button(action: { showAbout = true }) {
                        policyRow(title: "About", icon: "info.circle.fill")
                    }
                }
                .padding(.bottom, 20)

                // MARK: – Sign Out Button
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
                .padding(.bottom, 20)
            }
            .animation(.easeInOut, value: themeManager.isDarkMode)
        }
        .background(Color(UIColor.systemBackground))
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.top)
        .onChange(of: authManager.displayName) { _ in
            refreshID = UUID()
        }
        .sheet(isPresented: $isEditingName) {
            EditNameSheet(newName: $newName) {
                print("About to update name to: \(newName)")
                authManager.updateDisplayName(to: newName)
            }
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            LegalModalView(title: "Privacy Policy", content: "Your privacy policy goes here.")
        }
        .sheet(isPresented: $showTerms) {
            LegalModalView(title: "Terms of Service", content: "Terms and conditions go here.")
        }
        .sheet(isPresented: $showAbout) {
            LegalModalView(title: "About", content: "This app is developed to assist clinicians and students...")
        }
    }

    // MARK: – Helper Views

    func policyRow(title: String, icon: String) -> some View {
        HStack {
            Label(title, systemImage: icon)
            Spacer()
            Image(systemName: "chevron.right")
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
        .foregroundColor(.primary)
        .padding(.horizontal)
        .padding(.top, 8)
    }

    func settingToggle(label: String, systemImage: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Label(label, systemImage: systemImage)
            Spacer()
            Toggle("", isOn: isOn)
                .tint(.green)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.top, 8)
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
