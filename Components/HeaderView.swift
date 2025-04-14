//
//  HeaderView.swift
//  DrRaja Prototype #3
//
//  Created by Jonathan Hidrogo on 3/22/25.
//

import SwiftUI
import SwiftUICore

struct HeaderView: View {
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image("IMG_3423")
                .resizable()
                .scaledToFill()
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: 350
                )
                .clipped()
                // Extends the image into the top safe area
                .ignoresSafeArea(edges: .top)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Featured Procedure")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("A quick overview of a featured procedure with tags.")
                    .font(.body)
                    .foregroundColor(.white)
                    .lineLimit(3)
                
                Button(action: {}) {
                    Text("Learn More")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(8)
                }
            }
            .padding(.leading, 16)
            .padding(.bottom, 16)
        }
        // This ensures that the header view itself is not constrained by safe area insets at the top.
        .ignoresSafeArea(edges: .top)
    }
}
