//
//  ThemeManager.swift
//  DrRaja Prototype #3
//
//  Created by Jonathan Hidrogo on 3/22/25.
//

import SwiftUI

class ThemeManager: ObservableObject {
    // Automatically synced with UserDefaults
    @AppStorage("isDarkMode") var isDarkMode: Bool = UIScreen.main.traitCollection.userInterfaceStyle == .dark {
        willSet {
            objectWillChange.send() // Ensures views update when the theme changes
        }
    }

    // Optional theme colors you can customize app-wide
    @Published var primaryBackgroundColor: Color = Color(UIColor.systemBackground)
    @Published var secondaryTextColor: Color = Color.gray
    @Published var primaryTextColor: Color = Color.primary
}
