
//
//  ScreenProtectionManager.swift
//  DrRajaMed
//
//  Screen recording and screenshot protection for video content
//

import UIKit
import SwiftUI
import Combine
import AVFoundation  // Add this import

// MARK: - Screen Protection Manager

class ScreenProtectionManager: ObservableObject {
    @Published var isScreenRecordingDetected = false
    @Published var isScreenCaptureBlocked = false
    
    private var screenRecordingObserver: AnyCancellable?
    private var screenshotObserver: NSObjectProtocol?
    private var protectedViews: Set<UIView> = []
    
    static let shared = ScreenProtectionManager()
    
    private init() {
        setupScreenRecordingDetection()
        setupScreenshotDetection()
    }
    
    deinit {
        cleanup()
    }
    
    // MARK: - Public Methods
    
    /// Enable protection for a specific view
    func enableProtection(for view: UIView) {
        view.makeSecure()
        protectedViews.insert(view)
    }
    
    /// Disable protection for a specific view
    func disableProtection(for view: UIView) {
        view.removeSecure()
        protectedViews.remove(view)
    }
    
    /// Enable global screen recording detection
    func startMonitoring() {
        setupScreenRecordingDetection()
        setupScreenshotDetection()
    }
    
    /// Disable global monitoring
    func stopMonitoring() {
        cleanup()
    }
    
    // MARK: - Private Methods
    
    private func setupScreenRecordingDetection() {
        screenRecordingObserver = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.checkScreenRecordingStatus()
            }
    }
    
    private func setupScreenshotDetection() {
        screenshotObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.userDidTakeScreenshotNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleScreenshotDetected()
        }
    }
    
    private func checkScreenRecordingStatus() {
        let wasRecording = isScreenRecordingDetected
        isScreenRecordingDetected = UIScreen.main.isCaptured
        
        if isScreenRecordingDetected && !wasRecording {
            handleScreenRecordingStarted()
        } else if !isScreenRecordingDetected && wasRecording {
            handleScreenRecordingStopped()
        }
    }
    
    private func handleScreenRecordingStarted() {
        print("⚠️ Screen recording detected!")
        
        // Hide all protected views
        protectedViews.forEach { view in
            view.isHidden = true
        }
        
        // Post notification for UI updates
        NotificationCenter.default.post(
            name: .screenRecordingStarted,
            object: nil
        )
        
        // Optional: Show warning to user
        showScreenRecordingWarning()
    }
    
    private func handleScreenRecordingStopped() {
        print("✅ Screen recording stopped")
        
        // Show all protected views
        protectedViews.forEach { view in
            view.isHidden = false
        }
        
        // Post notification for UI updates
        NotificationCenter.default.post(
            name: .screenRecordingStopped,
            object: nil
        )
    }
    
    private func handleScreenshotDetected() {
        print("📸 Screenshot detected!")
        
        // Post notification for logging/analytics
        NotificationCenter.default.post(
            name: .screenshotTaken,
            object: nil
        )
        
        // Optional: Show warning to user
        showScreenshotWarning()
    }
    
    private func showScreenRecordingWarning() {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                let alert = UIAlertController(
                    title: "Screen Recording Detected",
                    message: "Video content is hidden while screen recording is active for content protection.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                window.rootViewController?.present(alert, animated: true)
            }
        }
    }
    
    private func showScreenshotWarning() {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                let alert = UIAlertController(
                    title: "Screenshot Detected",
                    message: "Screenshots of medical content may contain sensitive information. Please ensure compliance with privacy regulations.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "Understood", style: .default))
                window.rootViewController?.present(alert, animated: true)
            }
        }
    }
    
    private func cleanup() {
        screenRecordingObserver?.cancel()
        if let observer = screenshotObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        // Remove protection from all views
        protectedViews.forEach { view in
            view.removeSecure()
        }
        protectedViews.removeAll()
    }
}

// MARK: - UIView Extension for Screen Protection

extension UIView {
    private struct AssociatedKeys {
        static var secureTextField = "secureTextField"
        static var originalBackgroundColor = "originalBackgroundColor"
    }
    
    /// Make this view secure against screenshots and screen recording
    func makeSecure() {
        // Method 1: Use secure text field overlay (most effective)
        let secureField = UITextField()
        secureField.isSecureTextEntry = true
        secureField.isUserInteractionEnabled = false
        secureField.backgroundColor = .clear
        secureField.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(secureField)
        NSLayoutConstraint.activate([
            secureField.topAnchor.constraint(equalTo: topAnchor),
            secureField.leadingAnchor.constraint(equalTo: leadingAnchor),
            secureField.trailingAnchor.constraint(equalTo: trailingAnchor),
            secureField.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Store reference for cleanup
        objc_setAssociatedObject(self, &AssociatedKeys.secureTextField, secureField, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        // Method 2: Additional layer protection
        layer.isOpaque = true
        layer.contentsGravity = .center
    }
    
    /// Remove secure protection from this view
    func removeSecure() {
        if let secureField = objc_getAssociatedObject(self, &AssociatedKeys.secureTextField) as? UITextField {
            secureField.removeFromSuperview()
            objc_setAssociatedObject(self, &AssociatedKeys.secureTextField, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

// MARK: - SwiftUI View Modifier

struct ScreenProtectionModifier: ViewModifier {
    @StateObject private var protectionManager = ScreenProtectionManager.shared
    @State private var hostingController: UIHostingController<AnyView>?
    
    func body(content: Content) -> some View {
        content
            .background(ScreenProtectionViewRepresentable())
            .overlay(
                Group {
                    if protectionManager.isScreenRecordingDetected {
                        ZStack {
                            Color.black
                            VStack(spacing: 16) {
                                Image(systemName: "eye.slash.fill")
                                    .font(.system(size: 48))
                                    .foregroundColor(.white)
                                Text("Content Hidden")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                Text("Video content is hidden while screen recording is active")
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                        }
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.3), value: protectionManager.isScreenRecordingDetected)
                    }
                }
            )
            .onReceive(NotificationCenter.default.publisher(for: .screenshotTaken)) { _ in
                // Handle screenshot detection in SwiftUI
                handleScreenshotInSwiftUI()
            }
    }
    
    private func handleScreenshotInSwiftUI() {
        // Custom handling for screenshots in SwiftUI context
        print("Screenshot detected in SwiftUI view")
    }
}

struct ScreenProtectionViewRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        ScreenProtectionManager.shared.enableProtection(for: view)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // No updates needed
    }
    
    static func dismantleUIView(_ uiView: UIView, coordinator: ()) {
        ScreenProtectionManager.shared.disableProtection(for: uiView)
    }
}

// MARK: - SwiftUI View Extension

extension View {
    /// Apply screen protection to this view
    func screenProtected() -> some View {
        self.modifier(ScreenProtectionModifier())
    }
}

// MARK: - Notification Extensions

extension Notification.Name {
    static let screenRecordingStarted = Notification.Name("ScreenRecordingStarted")
    static let screenRecordingStopped = Notification.Name("ScreenRecordingStopped")
    static let screenshotTaken = Notification.Name("ScreenshotTaken")
}

// MARK: - Video Player Layer Integration

extension VideoPlayerLayer {
    func makeUIViewWithProtection(context: UIViewRepresentableContext<VideoPlayerLayer>) -> UIView {
        let view = UIView()
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspect
        view.layer.addSublayer(playerLayer)
        
        // Enable screen protection for video content
        ScreenProtectionManager.shared.enableProtection(for: view)
        
        DispatchQueue.main.async {
            playerLayer.frame = view.bounds
        }
        
        return view
    }
}
