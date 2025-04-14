//
//  HomeViewContent 2.swift
//  DrRaja Prototype #3
//
//  Created by Jonathan Hidrogo on 4/10/25.
//


import SwiftUI

struct HomeViewContent: View {
    let procedures: [ProcedureModel]
    let cases: [CaseModel]
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject var navigationManager = NavigationManager()
    @State private var selectedTab: BottomNavBar.Tab = .home
    
    // Define the header height as a constant (must match HeaderView's height)
    private let headerHeight: CGFloat = 350

    var body: some View {
        NavigationStack(path: $navigationManager.navigationPath) {
            ZStack(alignment: .top) {
                // The header image now sits at the very top and extends into the safe area.
                HeaderView()
                    .frame(height: headerHeight)
                    .ignoresSafeArea(edges: .top)
                
                VStack(spacing: 0) {
                    // Add empty space equal to header height so the ScrollView
                    // content starts below the header.
                    Spacer()
                        .frame(height: headerHeight)
                    
                    ScrollView {
                        LazyVStack(spacing: 5) {
                            // Procedures section
                            SectionHeader(
                                title: "Procedures",
                                destination: AnyView(ProceduresListView(procedures: procedures))
                            )
                            .background(Color(.systemBackground))
                            
                            HorizontalScrollView(items: procedures) { procedure in
                                Button(action: {
                                    navigationManager.navigateTo(.procedureDetail(procedure))
                                }) {
                                    ProcedureCardView(procedure: procedure)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            // Cases section
                            SectionHeader(
                                title: "Cases",
                                destination: AnyView(CaseListView(cases: cases))
                            )
                            .background(Color(.systemBackground))
                            
                            HorizontalScrollView(items: cases) { caseItem in
                                Button(action: {
                                    navigationManager.navigateTo(.caseDetail(caseItem))
                                }) {
                                    CaseCardView(caseItem: caseItem)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.bottom, 90)
                    }
                }
                
                // Bottom Navigation Bar
                VStack {
                    Spacer()
                    BottomNavBar(selectedTab: $selectedTab)
                        .environmentObject(navigationManager)
                }
            }
            .navigationDestination(for: NavigationManager.Destination.self) { destination in
                switch destination {
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
                case .procedureDetail(let procedure):
                    ProcedureDetailView(procedure: procedure)
                case .caseDetail(let caseItem):
                    CaseDetailView(caseItem: caseItem)
                }
            }
        }
        .environmentObject(navigationManager)
    }
}

struct HomeViewContent_Previews: PreviewProvider {
    static var previews: some View {
        HomeViewContent(procedures: procedures, cases: cases)
            .environmentObject(ThemeManager())
            .environmentObject(FavoritesManager())
            .environmentObject(NavigationManager())
            .environmentObject(AuthManager()) // If needed
    }
}
