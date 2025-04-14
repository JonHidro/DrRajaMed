//
//  Untitled.swift
//  DrRaja Prototype #3
//
//  Created by Jonathan Hidrogo on 3/22/25.
//

import SwiftUI

struct HomeViewContent: View {
    let procedures: [ProcedureModel]
    let cases: [CaseModel]

    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var navigationManager: NavigationManager

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(spacing: 0) {
                    Color.clear.frame(height: 350)

                    LazyVStack(spacing: 5) {
                        // Procedures Section
                        SectionHeader(
                            title: "Procedures",
                            destination: AnyView(ProceduresListView(procedures: procedures))
                        )
                        .background(Color(.systemBackground))

                        HorizontalScrollView(items: procedures) { procedure in
                            NavigationLink(
                                value: NavigationManager.Destination.procedureDetail(procedure)
                            ) {
                                ProcedureCardView(procedure: procedure)
                            }
                        }

                        // Cases Section
                        SectionHeader(
                            title: "Cases",
                            destination: AnyView(CaseListView(cases: cases))
                        )
                        .background(Color(.systemBackground))

                        HorizontalScrollView(items: cases) { caseItem in
                            NavigationLink(
                                value: NavigationManager.Destination.caseDetail(caseItem)
                            ) {
                                CaseCardView(caseItem: caseItem)
                            }
                        }
                    }
                    .padding(.bottom, 90)
                }
            }
            .ignoresSafeArea(edges: .top)

            HeaderView()
                .frame(height: 350)
                .ignoresSafeArea(edges: .top)
        }
    }
}

struct HomeViewContent_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
            .previewDevice("iPhone 14 Pro")
            .previewDisplayName("HomeView + BottomNavBar (Interactive)")
    }

    private struct PreviewWrapper: View {
        @StateObject var authManager       = AuthManager.preview
        @StateObject var navigationManager = NavigationManager()
        @StateObject var themeManager      = ThemeManager()
        @StateObject var userSettings      = UserSettings()
        @StateObject var favoritesManager  = FavoritesManager()

        @State private var selectedTab: BottomNavBar.Tab = .home

        var body: some View {
            ZStack(alignment: .bottom) {
                NavigationStack(path: $navigationManager.navigationPath) {
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
                .navigationDestination(for: NavigationManager.Destination.self) { destination in
                    switch destination {
                    case .procedureDetail(let proc):
                        ProcedureDetailView(procedure: proc)
                    case .caseDetail(let caseItem):
                        CaseDetailView(caseItem: caseItem)
                    }
                }

                BottomNavBar(selectedTab: $selectedTab)
            }
            .environmentObject(authManager)
            .environmentObject(navigationManager)
            .environmentObject(themeManager)
            .environmentObject(userSettings)
            .environmentObject(favoritesManager)
            .ignoresSafeArea(edges: .top)
        }
    }
}
