//
//  NotificationsView 2.swift
//  DrRaja Prototype #3
//
//  Created by Jonathan Hidrogo on 4/10/25.
//


import SwiftUI

struct NotificationsView: View {
    var body: some View {
        VStack(spacing: 0) {
            // Header
            ZStack(alignment: .topLeading) {
                RadialGradient(
                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                    center: .topLeading,
                    startRadius: 50,
                    endRadius: 400
                )
                .ignoresSafeArea(edges: .top)
                .frame(height: 140)

                Text("Notifications")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 50)
                    .padding(.leading, 16)
            }

            // Placeholder content
            Spacer()
            VStack(spacing: 12) {
                Image(systemName: "bell.slash.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.secondary)

                Text("No new notifications")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 40)
            Spacer()
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}
