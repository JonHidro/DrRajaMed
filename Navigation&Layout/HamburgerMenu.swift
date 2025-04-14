//
//  HamburgerMenu.swift
//  DrRaja Prototype #3
//
//  Created by Jonathan Hidrogo on 3/22/25.
//

import SwiftUI

struct HamburgerMenu: View {
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        Menu {
            Button("Profile", action: { handleMenuSelection(.profile) })
            
            Button(action: {
                // Toggle theme when tapped.
                DispatchQueue.main.async {
                    themeManager.isDarkMode.toggle()
                    print("Theme toggled. isDarkMode is now \(themeManager.isDarkMode)")
                }
            }) {
                HStack {
                    Image(systemName: themeManager.isDarkMode ? "sun.max.fill" : "moon.fill")
                        .font(.title2)
                        .padding(8)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Circle())
                    Text("Change Theme")
                }
            }
            
            Button("Sign In / Sign Out", action: { handleMenuSelection(.signInOut) })
        } label: {
            Image(systemName: "line.horizontal.3")
                .font(.system(size: 35, weight: .bold))
                .frame(width: 50, height: 50)
                .background(Color.clear)
                .contentShape(Rectangle())
        }
        .padding(.trailing, 20)
        .padding(.top, 12)
    }

    private enum MenuAction { case profile, signInOut }

    private func handleMenuSelection(_ action: MenuAction) {
        switch action {
        case .profile:
            print("Profile tapped")
        case .signInOut:
            print("Sign In/Sign Out tapped")
        }
    }
}

