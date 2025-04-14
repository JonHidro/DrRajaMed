//
//  CustomTabBar.swift
//  DrRaja Prototype #3
//
//  Created by Jonathan Hidrogo on 4/9/25.
//

import SwiftUI

struct BottomNavBar: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @Binding var selectedTab: Tab

    // Optional closure to notify parent of tab selection
    var onTabSelected: ((Tab) -> Void)? = nil

    enum Tab {
        case home, search, favorites, notifications, profile
    }

    var body: some View {
        HStack(spacing: 0) {
            TabButton(tab: .home, currentTab: $selectedTab, icon: "house.fill") {
                handleTabSelection(.home)
            }

            TabButton(tab: .search, currentTab: $selectedTab, icon: "magnifyingglass") {
                handleTabSelection(.search)
            }

            TabButton(tab: .favorites, currentTab: $selectedTab, icon: "heart.fill") {
                handleTabSelection(.favorites)
            }

            TabButton(tab: .notifications, currentTab: $selectedTab, icon: "bell.fill") {
                handleTabSelection(.notifications)
            }

            TabButton(tab: .profile, currentTab: $selectedTab, icon: "person.fill") {
                handleTabSelection(.profile)
            }
        }
        .frame(height: 60)
        .background(Color(UIColor.systemBackground))
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -2)
    }

    /// Handles tab selection and triggers navigation reset
    private func handleTabSelection(_ tab: Tab) {
        selectedTab = tab
        onTabSelected?(tab)
    }
}

// MARK: - Tab Button Component
struct TabButton: View {
    let tab: BottomNavBar.Tab
    @Binding var currentTab: BottomNavBar.Tab
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(currentTab == tab ? .blue : .gray)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
