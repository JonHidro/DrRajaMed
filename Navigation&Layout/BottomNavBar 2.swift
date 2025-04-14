//
//  BottomNavBar 2.swift
//  DrRaja Prototype #3
//
//  Created by Jonathan Hidrogo on 4/10/25.
//


import SwiftUI

struct BottomNavBar: View {
    // The selectedTab is bound to the MainContainerView's state.
    @Binding var selectedTab: BottomNavBar.Tab
    
    enum Tab {
        case home, search, favorites, notifications, profile
    }
    
    var body: some View {
        HStack(spacing: 0) {
            tabButton(tab: .home, icon: "house.fill") {
                selectedTab = .home
            }
            
            tabButton(tab: .search, icon: "magnifyingglass") {
                selectedTab = .search
            }
            
            tabButton(tab: .favorites, icon: "heart.fill") {
                selectedTab = .favorites
            }
            
            tabButton(tab: .notifications, icon: "bell.fill") {
                selectedTab = .notifications
            }
            
            tabButton(tab: .profile, icon: "person.fill") {
                selectedTab = .profile
            }
        }
        .frame(height: 60)
        .background(Color(UIColor.systemBackground))
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -2)
    }
    
    @ViewBuilder
    func tabButton(tab: Tab, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(selectedTab == tab ? .blue : .gray)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct BottomNavBar_Previews: PreviewProvider {
    static var previews: some View {
        BottomNavBar(selectedTab: .constant(.home))
            .previewLayout(.sizeThatFits)
    }
}
