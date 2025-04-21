//
//  FavoritesView.swift
//  DrRaja Prototype #3
//
//  Created by Jonathan Hidrogo on 3/23/25.
//

import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var favorites: FavoritesManager
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack(spacing: 0) {
            // MARK: – Header with lowered title (matching other views)
            ZStack(alignment: .bottomLeading) {
                RadialGradient(
                    gradient: Gradient(colors: [Color.blue, Color.teal]),
                    center: .topLeading,
                    startRadius: 50,
                    endRadius: 400
                )
                .ignoresSafeArea(edges: .top)
                .frame(height: 100) // Reduced height to match ProfileView
                
                HStack {
                    Text("Favorites")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.leading, 16)

                    Spacer()

                    if !favorites.procedures.isEmpty || !favorites.cases.isEmpty {
                        Button {
                            favorites.procedures.removeAll()
                            favorites.cases.removeAll()
                        } label: {
                            Image(systemName: "trash")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                        .padding(.trailing, 16)
                        .accessibilityLabel("Clear all favorites")
                    }
                }
                .padding(.bottom, 1) // Using 1 as requested instead of 10
            }

            // MARK: – Content
            ScrollView {
                VStack(spacing: 24) {
                    if favorites.procedures.isEmpty && favorites.cases.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "heart.slash")
                                .font(.system(size: 60))
                                .foregroundColor(.secondary)
                            Text("No favorites yet")
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 60)
                    } else {
                        if !favorites.procedures.isEmpty {
                            SectionHeader(
                                title: "Procedures",
                                destination: AnyView(ProceduresListView(procedures: favorites.procedures))
                            )
                            HorizontalScrollView(items: favorites.procedures) { proc in
                                NavigationLink(destination: ProcedureDetailView(procedure: proc)) {
                                    ProcedureCardView(procedure: proc)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }

                        if !favorites.cases.isEmpty {
                            SectionHeader(
                                title: "Cases",
                                destination: AnyView(CaseListView(cases: favorites.cases))
                            )
                            HorizontalScrollView(items: favorites.cases) { c in
                                NavigationLink(destination: CaseDetailView(caseItem: c)) {
                                    CaseCardView(caseItem: c)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                .padding(.vertical, 16)
                .padding(.horizontal)
            }
        }
        .navigationBarHidden(true) // Hide the navigation bar
        .edgesIgnoringSafeArea(.top)
        .environment(\.colorScheme, themeManager.isDarkMode ? .dark : .light)
    }
}
