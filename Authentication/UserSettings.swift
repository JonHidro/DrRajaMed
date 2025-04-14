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
}
