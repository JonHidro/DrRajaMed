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

    // Controls which tab’s root screen is visible
    @State private var selectedTab: BottomNavBar.Tab = .home

    var body: some View {
        ZStack(alignment: .bottom) {
            // ────────────────────────────────────────────────────
            // 1) Single NavigationStack for all pushes and pops
            NavigationStack(path: $navigationManager.navigationPath) {
                Group {
                    if !authManager.isSignedIn {
                        // If user is not signed in, show SignInView
                        SignInView()
                    } else {
                        // Display root view for selected tab
                        switch selectedTab {
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
            .id(selectedTab) // ✅ Forces view stack to reset and re-render on tab switch

            // ────────────────────────────────────────────────────
            // 2) Only show the BottomNavBar once signed in
            if authManager.isSignedIn {
                BottomNavBar(selectedTab: $selectedTab) { newTab in
                    if selectedTab != newTab {
                        selectedTab = newTab
                    }

                    // Always reset the stack regardless of same or new tab
                    navigationManager.navigationPath = NavigationPath()
                }
                .environmentObject(navigationManager)
            }
        }
    }
}

struct MainContainerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Preview: Signed-out (no bottom bar)
            MainContainerView(procedures: procedures, cases: cases)
                .environmentObject({
                    let auth = AuthManager()
                    auth.isSignedIn = false
                    return auth
                }())
                .environmentObject(NavigationManager())
                .environmentObject(ThemeManager())
                .environmentObject(UserSettings())
                .environmentObject(FavoritesManager())
                .previewDisplayName("Signed-Out")

            // Preview: Signed-in (bottom bar visible)
            MainContainerView(procedures: procedures, cases: cases)
                .environmentObject({
                    let auth = AuthManager()
                    auth.isSignedIn = true
                    return auth
                }())
                .environmentObject(NavigationManager())
                .environmentObject(ThemeManager())
                .environmentObject(UserSettings())
                .environmentObject(FavoritesManager())
                .previewDisplayName("Home with Bottom Bar")
        }
    }
}
