//
//  DrRaja_Prototype__3App.swift
//  DrRaja Prototype #3
//
//  Created by Jonathan Hidrogo on 1/7/25.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct DrRajaMed: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @StateObject private var authManager       = AuthManager()
    @StateObject private var themeManager      = ThemeManager()
    @StateObject private var userSettings      = UserSettings()
    @StateObject private var favoritesManager  = FavoritesManager()
    @StateObject private var navigationManager = NavigationManager()
    @StateObject private var appState          = AppState()

    var body: some Scene {
        WindowGroup {
            MainContainerView(
                procedures: procedures,
                cases: cases
            )
            .environmentObject(authManager)
            .environmentObject(themeManager)
            .environmentObject(userSettings)
            .environmentObject(favoritesManager)
            .environmentObject(navigationManager)
            .environmentObject(appState)
            .preferredColorScheme(themeManager.isDarkMode ? .dark : .light) // ✅ Global override
        }
    }
}
