//
//  NotificationsView.swift
//  DrRaja Prototype #3
//
//  Created by Jonathan Hidrogo on 3/23/25.
//

import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack(spacing: 0) {
            // MARK: – Fixed header
            ZStack(alignment: .bottomLeading) {
                RadialGradient(
                    gradient: Gradient(colors: [Color.orange, Color.red]),
                    center: .topLeading,
                    startRadius: 50,
                    endRadius: 400
                )
                .ignoresSafeArea(edges: .top)
                .frame(height: 100)
                
                Text("Notifications")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.leading, 16)
                    .padding(.bottom, 1)
            }

            // MARK: – Scrollable content
            ScrollView {
                VStack(spacing: 24) {
                    Spacer(minLength: 40)
                    
                    Image(systemName: "bell.slash.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    
                    Text("No new notifications")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    Spacer()  // if you want bottom padding
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .padding(.horizontal)
            }
        }
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.top)
        .environment(\.colorScheme, themeManager.isDarkMode ? .dark : .light)
    }
}

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            NotificationsView()
                .environmentObject(ThemeManager())
        }
    }
}
