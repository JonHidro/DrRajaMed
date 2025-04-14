//
//  RootCustomTabView.swift
//  DrRaja Prototype #3
//
//  Created by Jonathan Hidrogo on 4/8/25.
//

import SwiftUI

struct RootCustomTabView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        ZStack(alignment: .bottom) {
            // Single NavigationStack for all tabs
            NavigationStack {
                switch selectedTab {
                case 0:
                    HomeView(procedures: procedures, cases: cases)
                        .environmentObject(themeManager)
                        .navigationBarHidden(true)
                case 1:
                    ProceduresListView(procedures: procedures)
                case 2:
                    CaseListView(cases: cases)
                default:
                    HomeView(procedures: procedures, cases: cases)
                        .environmentObject(themeManager)
                        .navigationBarHidden(true)
                }
            }

            // Persistent tab bar
            CustomTabBar(selectedTab: $selectedTab)
        }
        .edgesIgnoringSafeArea(.bottom)
        .environment(\.colorScheme, themeManager.isDarkMode ? .dark : .light)
    }
}
