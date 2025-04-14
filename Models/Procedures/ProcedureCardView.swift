//
//  ProcedureCardView.swift
//  DrRaja Prototype #3
//
//  Created by Jonathan Hidrogo on 3/22/25.
//

import SwiftUI

struct ProcedureCardView: View {
    let procedure: ProcedureModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(procedure.imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 100)
                .clipped()
                .cornerRadius(8)

            Text(procedure.name)
                .font(.headline)
                .lineLimit(1)
                .foregroundColor(.accentColor)

            Text(procedure.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)

            HStack {
                ForEach(procedure.cardTags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption)
                        .padding(.horizontal, 8)
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
        .contentShape(Rectangle())  // Ensures the entire area is tappable.
    }

    private func tagColor(_ tag: String) -> Color {
        switch tag.uppercased() {
        case "SFA", "PTCA":
            return .red
        case "ILIAC", "CORONARY":
            return .green
        case "FEMORAL":
            return Color.pink
        default:
            return .gray
        }
    }
}
