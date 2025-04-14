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
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                Spacer()
            }
            .contentShape(Rectangle())    // ← entire row tappable
            .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
