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

    // Drives actual view rendering (can be briefly de-synced from selectedTab)
    @State private var renderTab: Tab = .home

    var body: some View {
        ZStack(alignment: .bottom) {
            // 1) NavigationStack handles routing
            NavigationStack(path: $navigationManager.navigationPath) {
                VStack {
                    if !authManager.isSignedIn {
                        AuthGateView() // Handles both SignIn and SignUp flow
                    } else {
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

            // 2) BottomNavBar (shown when signed in)
            if authManager.isSignedIn {
                BottomNavBar(selectedTab: $appState.selectedTab) { newTab in
                    if newTab == .home && appState.selectedTab == .home {
                        // Trigger refresh by briefly changing tab
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
            renderTab = appState.selectedTab
        }
        .onChange(of: authManager.isSignedIn) {
            if $0 {
                appState.selectedTab = .home
                renderTab = .home
            }
        }
        .environmentObject(appState)
    }
}
