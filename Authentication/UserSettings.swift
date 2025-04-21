//
//  UserSettings.swift
//  DrRaja Prototype #3
//
//  Created by Jonathan Hidrogo on 3/24/25.
//

import SwiftUI

class UserSettings: ObservableObject {
    @Published var userMode: String = "Student"
    @Published var hasCompletedOnboarding: Bool = false

    // Placeholder method to save user settings.
    func saveSettings() {
        // TODO: Implement logic to save user settings to persistent storage (e.g., UserDefaults).
        print("Saving user settings...")
    }

    // Placeholder method to load user settings.
    func loadSettings() {
        // TODO: Implement logic to load user settings from persistent storage (e.g., UserDefaults).
        print("Loading user settings...")
    }

    // Placeholder method to change user mode
    func changeUserMode(to newMode: String){
        userMode = newMode
        print("Changing user mode to \(newMode)")
    }
}
