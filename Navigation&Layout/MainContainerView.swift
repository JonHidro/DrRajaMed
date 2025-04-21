//
//  MainContainerView.swift
//  DrRaja Prototype #3
//
//  Created by Jonathan Hidrogo on 4/9/25.
//

import SwiftUI

struct MainContainerView: View {
    // Injected globals for procedures and cases
    let procedures: [ProcedureModel]
    let cases: [CaseModel]

    // Environment objects from @main
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var appState: AppState

    // NEW: Drives actual view rendering (can be de-synced briefly from selectedTab)
    @State private var renderTab: Tab = .home

    var body: some View {
        ZStack(alignment: .bottom) {
            // 1) NavigationStack handles all routing centrally
            NavigationStack(path: $navigationManager.navigationPath) {
                VStack {
                    if !authManager.isSignedIn {
                        AuthGateView() // Handles both SignIn and SignUp flow
                    }
                        else {
                        // Use renderTab to drive which view is displayed
                        switch renderTab {
                        case .home:
                            HomeViewContent(procedures: procedures, cases: cases)
                        case .search:
                            SearchView(cases: cases, procedures: procedures)
                        case .favorites:
                            FavoritesView()
                        case .notifications:
                            NotificationsView()
                        case .profile:
                            ProfileView()
                        }
                    }
                }
                .navigationDestination(for: NavigationManager.Destination.self) { destination in
                    switch destination {
                    case .procedureDetail(let procedure):
                        ProcedureDetailView(procedure: procedure)
                    case .caseDetail(let caseItem):
                        CaseDetailView(caseItem: caseItem)
                    }
                }
            }
            .id(appState.selectedTab)

            // 2) Persistent BottomNavBar once signed in
            if authManager.isSignedIn {
                BottomNavBar(selectedTab: $appState.selectedTab) { newTab in
                    if newTab == .home && appState.selectedTab == .home {
                        // Fake tab switch to refresh HomeViewContent
                        appState.selectedTab = .profile
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            appState.selectedTab = .home
                            navigationManager.goToRoot()
                            renderTab = .home
                        }
                    } else {
                        appState.selectedTab = newTab
                        navigationManager.goToRoot()
                        renderTab = newTab
                    }
                }
                .environmentObject(navigationManager)
            }
        }
        .onAppear {
            // Initial sync of visual rendering tab
            renderTab = appState.selectedTab
        }
        .environmentObject(appState)
    }
}
