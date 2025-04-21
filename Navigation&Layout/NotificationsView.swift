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
        ScrollView {
            VStack(spacing: 0) {
                // Header with lowered title (matching ProfileView)
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
                        .padding(.bottom, 01)
                }
                
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "bell.slash.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                        .padding(.top, 40)
                    
                    Text("No new notifications")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
                Spacer()
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
