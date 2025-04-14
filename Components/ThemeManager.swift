//
//  ThemeManager.swift
//  DrRaja Prototype #3
//
//  Created by Jonathan Hidrogo on 3/22/25.
//

import SwiftUI

class ThemeManager: ObservableObject {
    // A stored property with @Published, plus a didSet to save changes.
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        }
    }
    
    init() {
        // If "isDarkMode" is already in UserDefaults, use that.
        // Otherwise, pick up the current system appearance.
        if UserDefaults.standard.object(forKey: "isDarkMode") != nil {
            self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        } else {
            self.isDarkMode = UIScreen.main.traitCollection.userInterfaceStyle == .dark
        }
    }
}

struct ThemedContainer<Content: View>: View {
    @EnvironmentObject var themeManager: ThemeManager
    let content: Content

    var body: some View {
        content.environment(\.colorScheme, themeManager.isDarkMode ? .dark : .light)
    }
}
