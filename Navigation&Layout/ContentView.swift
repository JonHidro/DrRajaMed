//
//  ContentView.swift
//  DrRajaMed
//
//  Created by Jonathan Hidrogo on 4/16/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appViewModel: AppViewModel // Add AppViewModel


    @EnvironmentObject var authManager:      AuthManager
    @EnvironmentObject var navigationManager: NavigationManager

    var body: some View {
        NavigationStack(path: $navigationManager.navigationPath) {
            if authManager.isSignedIn {
                HomeViewContent(procedures: appViewModel.procedures, cases: appViewModel.cases) // Access data from AppViewModel
            } else {
                SignInView()
            }
        }
        .navigationDestination(for: NavigationManager.Destination.self) { destination in
            switch destination {
            case .home:
                HomeViewContent(procedures: appViewModel.procedures, cases: appViewModel.cases) // Access data from AppViewModel

            case .search:
                // pass the right arrays here:
                SearchView(cases:       appViewModel.cases, // Access data from AppViewModel
                           procedures: appViewModel.procedures) // Access data from AppViewModel

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
