//
//  SectionHeader.swift
//  DrRaja Prototype #3
//
//  Created by Jonathan Hidrogo on 3/22/25.
//

import SwiftUI

struct SectionHeader: View {
    let title: String
    let destination: AnyView

    var body: some View {
        NavigationLink(destination: destination) {
            HStack {
                Text(title)
                    .font(.title2).bold()
                    .foregroundColor(.primary)
                    .padding(.top, 5) // Add a small top padding (adjust the value as needed)
                Spacer()
                Text("See All")
                    .foregroundColor(.blue)
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .contentShape(Rectangle())    // ← entire row tappable
            .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
