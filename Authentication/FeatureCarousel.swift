//
//  FeatureCarousel.swift
//  DrRaja Prototype #3
//
//  Created by Jonathan Hidrogo on 3/23/25.
//

import SwiftUI

// FeatureCarousel.swift - Displays feature highlights
struct FeatureCarousel: View {
    var body: some View {
        TabView {
            // First Tab: Branding and Introduction
            VStack(spacing: 20) {
                Image("image") // Your SVG logo
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .padding(.bottom, 10)

                HStack(spacing: 0) {
                    Text("DrRaja")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black.opacity(0.9))

                    Text("Labs")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
                .padding(.bottom, 50)

                Text("Gain exclusive access into the virtual library of renowned interventional cardiologist Dr. Raja.")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            }
            .padding(.bottom, 30)

            // Feature Cards
            FeatureCard(
                icon: "video",
                title: "Procedures",
                description: "Experience live and prerecorded procedures"
            )
            FeatureCard(
                icon: "chart.bar",
                title: "Cases",
                description: "View a detailed database of specific cases with real-time updates"
            )
            FeatureCard(
                icon: "laptopcomputer",
                title: "Consult",
                description: "Ask questions and receive personalized advice directly from Dr. Raja."
            )
        }
        .tabViewStyle(PageTabViewStyle())
        .frame(height: 360)
    }
}

// FeatureCard.swift - Single feature card
struct FeatureCard: View {
    var icon: String
    var title: String
    var description: String
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.blue)
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
            Text(description)
                .font(.subheadline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
