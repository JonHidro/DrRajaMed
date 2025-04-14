//
//  ProfileView.swift
//  DrRaja Prototype #3
//
//  Created by Jonathan Hidrogo on 3/23/25.
//

import SwiftUI

struct ProfileView: View {
    // Inject your AuthManager so we can sign out
    @EnvironmentObject var authManager:      AuthManager
    @EnvironmentObject var navigationManager: NavigationManager

    var body: some View {
        VStack(spacing: 0) {
            // MARK: – Header
            ZStack(alignment: .topLeading) {
                RadialGradient(
                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                    center: .topLeading,
                    startRadius: 50,
                    endRadius: 400
                )
                .ignoresSafeArea(edges: .top)
                .frame(height: 140)

                Text("Profile")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 50)
                    .padding(.leading, 16)
            }

            Spacer()

            // MARK: – Placeholder Content
            VStack(spacing: 12) {
                Image(systemName: "person.crop.circle")
                    .font(.system(size: 60))
                    .foregroundColor(.secondary)

                Text("User profile and settings will appear here.")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.top, 40)

            Spacer()

            // MARK: – Sign Out Button
            Button(action: {
                // 1) Sign out from Firebase/Google/Apple
                authManager.signOut()
                // 2) Clear any pushed views (optional)
                navigationManager.goToRoot()
            }) {
                Text("Sign Out")
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.horizontal, 16)
            }
            .padding(.bottom, 20)
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview with all environment objects
        NavigationStack {
            ProfileView()
        }
        .environmentObject(AuthManager.preview)
        .environmentObject(NavigationManager())
        .previewDevice("iPhone 14 Pro")
    }
}
