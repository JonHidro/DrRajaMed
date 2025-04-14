//
//  ProceduresList.swift
//  DrRaja Prototype #3
//
//  Created by Jonathan Hidrogo on 3/22/25.
//

import SwiftUI

struct ProceduresListView: View {
    let procedures: [ProcedureModel]

    var body: some View {
        List(procedures) { proc in
            NavigationLink(destination: ProcedureDetailView(procedure: proc)) {
                HStack {
                    Image(proc.imageName)
                        .resizable()
                        .frame(width: 50, height: 50)
                        .cornerRadius(8)
                    VStack(alignment: .leading) {
                        Text(proc.name)
                            .font(.headline)
                        Text(proc.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle("Procedures")
    }
}
