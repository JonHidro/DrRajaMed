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
        
        // Initialize screen protection monitoring
        ScreenProtectionManager.shared.startMonitoring()
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Clean up screen protection when app terminates
        ScreenProtectionManager.shared.stopMonitoring()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Optional: Additional security when app goes to background
        // You can add extra protection here if needed
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Re-verify protection status when app comes back to foreground
        ScreenProtectionManager.shared.startMonitoring()
    }
}

@main
struct DrRajaMed: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @StateObject private var authManager         = AuthManager()
    @StateObject private var subscriptionManager = SubscriptionManager()
    @StateObject private var themeManager        = ThemeManager()
    @StateObject private var userSettings        = UserSettings()
    @StateObject private var favoritesManager    = FavoritesManager()
    @StateObject private var navigationManager   = NavigationManager()
    @StateObject private var appState            = AppState()

    var body: some Scene {
        WindowGroup {
            Group {
                if !authManager.isSignedIn {
                    AuthGateView()
                } else if subscriptionManager.isLoading {
                    // Show main content while checking subscription in background
                    MainContainerView(
                        procedures: procedures,
                        cases: cases
                    )
                } else if subscriptionManager.isSubscribed {
                    MainContainerView(
                        procedures: procedures,
                        cases: cases
                    )
                } else {
                    PaywallView()
                }
            }
            .environmentObject(authManager)
            .environmentObject(subscriptionManager)
            .environmentObject(themeManager)
            .environmentObject(userSettings)
            .environmentObject(favoritesManager)
            .environmentObject(navigationManager)
            .environmentObject(appState)
            .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
            .onAppear {
                authManager.subscriptionManager = subscriptionManager
                setupScreenProtectionHandling()
            }
            .onReceive(NotificationCenter.default.publisher(for: .screenRecordingStarted)) { _ in
                handleScreenRecordingStarted()
            }
            .onReceive(NotificationCenter.default.publisher(for: .screenRecordingStopped)) { _ in
                handleScreenRecordingStopped()
            }
            .onReceive(NotificationCenter.default.publisher(for: .screenshotTaken)) { _ in
                handleScreenshotTaken()
            }
        }
    }
    
    // MARK: - Screen Protection Handling
    
    private func setupScreenProtectionHandling() {
        // Any initial setup needed for screen protection
        print("🛡️ Screen protection initialized for DrRajaMed")
    }
    
    private func handleScreenRecordingStarted() {
        print("⚠️ Screen recording detected - App-wide protection activated")
        
        // Optional: You can add app-wide reactions here
        // For example:
        // - Pause all video players
        // - Show a global overlay
        // - Log security events
        // - Send analytics
        
        // Example: Pause any active video players
        NotificationCenter.default.post(
            name: Notification.Name("PauseAllVideoPlayers"),
            object: nil
        )
    }
    
    private func handleScreenRecordingStopped() {
        print("✅ Screen recording stopped - Content protection restored")
        
        // Optional: Resume any paused content
        NotificationCenter.default.post(
            name: Notification.Name("ResumeVideoPlayersIfNeeded"),
            object: nil
        )
    }
    
    private func handleScreenshotTaken() {
        print("📸 Screenshot detected - Logged for compliance")
        
        // Optional: Log screenshot events for compliance/analytics
        // You could send this to your analytics service
        logSecurityEvent(type: "screenshot", context: "app_wide")
    }
    
    private func logSecurityEvent(type: String, context: String) {
        // Implement your logging/analytics here
        // This could be sent to Firebase Analytics, your own backend, etc.
        print("🔒 Security Event - Type: \(type), Context: \(context), Timestamp: \(Date())")
        
        // Example Firebase Analytics call:
        // Analytics.logEvent("security_event", parameters: [
        //     "event_type": type,
        //     "context": context,
        //     "user_id": authManager.currentUser?.id ?? "unknown"
        // ])
    }
}
