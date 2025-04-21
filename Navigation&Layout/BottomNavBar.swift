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
            TabButton(tab: .home, currentTab: $selectedTab, icon: "house.fill") {
                if selectedTab == .home {
                    // Temporarily switch tabs to trigger SwiftUI refresh
                    selectedTab = .profile
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        selectedTab = .home
                        navigationManager.goToRoot()
                    }
                } else {
                    navigationManager.goToRoot()
                    triggerHapticFeedbackAndUpdateTab(.home)
                }
            }
  


            TabButton(tab: .search, currentTab: $selectedTab, icon: "magnifyingglass") {
                triggerHapticFeedbackAndUpdateTab(.search)
            }

            TabButton(tab: .favorites, currentTab: $selectedTab, icon: "heart.fill") {
                triggerHapticFeedbackAndUpdateTab(.favorites)
            }

            TabButton(tab: .notifications, currentTab: $selectedTab, icon: "bell.fill") {
                triggerHapticFeedbackAndUpdateTab(.notifications)
            }

            TabButton(tab: .profile, currentTab: $selectedTab, icon: "person.fill") {
                triggerHapticFeedbackAndUpdateTab(.profile)
            }
        }
        .frame(height: 60)
        .background(Color(UIColor.systemBackground))
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -2)
        .onAppear {
            // Prepare haptic engine when view appears
            hapticImpact.prepare()
        }
    }

    /// Triggers haptic feedback and updates the selected tab
    private func triggerHapticFeedbackAndUpdateTab(_ tab: Tab) {
        // Only trigger haptic feedback if we're changing tabs
        if selectedTab != tab {
            hapticImpact.impactOccurred()
        }
        
        // Update the tab and notify parent
        selectedTab = tab
        onTabSelected?(tab)
    }
}

// MARK: - Tab Button Component
struct TabButton: View {
    let tab: Tab
    @Binding var currentTab: Tab
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
