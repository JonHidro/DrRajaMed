//
//  CaseCardView.swift
//  DrRaja Prototype #3
//
//  Created by Jonathan Hidrogo on 3/22/25.
//

import SwiftUI

struct CaseCardView: View {
    let caseItem: CaseModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationLink(destination: CaseDetailView(caseItem: caseItem)) {
            VStack(alignment: .leading, spacing: 8) {
                Image(caseItem.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 100)
                    .clipped()
                    .cornerRadius(8)

                Text(caseItem.title)
                    .font(.headline)
                    .lineLimit(1)
                    .foregroundColor(.blue)

                Text(caseItem.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                HStack {
                    ForEach(caseItem.cardTags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .background(tagColor(tag))
                            .foregroundColor(.white)
                            .cornerRadius(5)
                    }
                }
            }
            .padding(10)
            .frame(width: 180)
            .background(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1),
                    radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle()) // Prevents default button styling
    }

    private func tagColor(_ tag: String) -> Color {
        switch tag.uppercased() {
        case "LAD":
            return .teal
        case "RCA":
            return .purple
        case "ACUTE":
            return .red
        case "SUBACUTE":
            return .orange
        default:
            return .gray
        }
    }
}
