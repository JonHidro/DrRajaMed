//
//  CasesList.swift
//  DrRaja Prototype #3
//
//  Created by Jonathan Hidrogo on 3/22/25.
//

import SwiftUI

struct CaseListView: View {
    let cases: [CaseModel]

    var body: some View {
        List(cases) { item in
            NavigationLink(destination: CaseDetailView(caseItem: item)) {
                Text(item.title)
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle("Cases")
    }
}
