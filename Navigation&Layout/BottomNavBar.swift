//
//  CustomTabBar.swift
//  DrRaja Prototype #3
//
//  Created by Jonathan Hidrogo on 4/9/25.
//

import SwiftUI
import UIKit

struct BottomNavBar: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @Binding var selectedTab: Tab
    
    // Optional closure to notify parent of tab selection
    var onTabSelected: ((Tab) -> Void)? = nil
    
    // Haptic feedback generator
    let hapticImpact = UIImpactFeedbackGenerator(style: .medium)

    var body: some View {
        HStack(spacing: 0) {
            tabItem(.home,       icon: "house.fill")
            tabItem(.search,     icon: "magnifyingglass")
            tabItem(.favorites,  icon: "heart.fill")
            tabItem(.notifications, icon: "bell.fill")
            tabItem(.profile,    icon: "person.fill")
        }
        .frame(height: 60)
        .background(Color(UIColor.systemBackground))
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -2)
        .onAppear {
            hapticImpact.prepare()
        }
    }

    // MARK: - Helpers

    private func tabItem(_ tab: Tab, icon: String) -> some View {
        TabButton(
            tab: tab,
            currentTab: $selectedTab,
            icon: icon,
            activeColor: color(for: tab)
        ) {
            if tab == .home && selectedTab == .home {
                // special “pop to root” hack
                selectedTab = .profile
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    selectedTab = .home
                    navigationManager.goToRoot()
                }
            } else {
                if tab == .home {
                    navigationManager.goToRoot()
                }
                triggerHapticFeedbackAndUpdateTab(tab)
            }
        }
    }

    private func triggerHapticFeedbackAndUpdateTab(_ tab: Tab) {
        if selectedTab != tab {
            hapticImpact.impactOccurred()
        }
        selectedTab = tab
        onTabSelected?(tab)
    }

    private func color(for tab: Tab) -> Color {
        switch tab {
        case .home:         return .blue
        case .search:       return .green
        case .favorites:    return .red
        case .notifications:return .orange
        case .profile:      return .purple
        }
    }
}

struct TabButton: View {
    let tab: Tab
    @Binding var currentTab: Tab
    let icon: String
    let activeColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(currentTab == tab ? activeColor : .gray)
                
                Circle()
                    .fill(currentTab == tab ? activeColor : .clear)
                    .frame(width: 6, height: 6)
            }
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity)
        }
    }
}
