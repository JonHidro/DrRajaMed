//
//  ContentView.swift
//  DrRaja Prototype #3
//
//  Created by Jonathan Hidrogo on 3/28/25.
//

import SwiftUI

struct ContentView: View {
    // ① Injected data:
    let procedures: [ProcedureModel]
    let cases:       [CaseModel]

    @EnvironmentObject var authManager:      AuthManager
    @EnvironmentObject var navigationManager: NavigationManager

    var body: some View {
        NavigationStack(path: $navigationManager.navigationPath) {
            if authManager.isSignedIn {
                HomeViewContent(procedures: procedures, cases: cases)
            } else {
                SignInView()
            }
        }
        .navigationDestination(for: NavigationManager.Destination.self) { destination in
            switch destination {
            case .home:
                HomeViewContent(procedures: procedures, cases: cases)

            case .search:
                // pass the right arrays here:
                SearchView(cases:       cases,
                           procedures: procedures)

            case .favorites:
                FavoritesView()

            case .notifications:
                NotificationsView()

            case .profile:
                ProfileView()

            case .procedureDetail(let procedure):
                ProcedureDetailView(procedure: procedure)

            case .caseDetail(let caseItem):
                CaseDetailView(caseItem: caseItem)
            }
        }
    }
}

