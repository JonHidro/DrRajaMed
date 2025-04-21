//
//  ProceduresList.swift
//  DrRaja Prototype #3
//
//  Created by Jonathan Hidrogo on 3/22/25.
//

import SwiftUI

struct ProceduresListView: View {
    let procedures: [ProcedureModel]
    @EnvironmentObject var favorites: FavoritesManager

    var body: some View {
        List(procedures) { procedure in
            NavigationLink(destination: ProcedureDetailView(procedure: procedure)
                            .environmentObject(favorites)) {
                HStack(spacing: 12) {
                    Image(procedure.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .cornerRadius(8)
                        .clipped()

                    VStack(alignment: .leading, spacing: 4) {
                        Text(procedure.name)
                            .font(.headline)
                        Text(procedure.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                .padding(.vertical, 4)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .listStyle(PlainListStyle())
        .navigationTitle("Procedures")
    }
}

