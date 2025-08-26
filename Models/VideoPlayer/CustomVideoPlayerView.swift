import SwiftUI
import AVKit

struct CustomVideoPlayerView: View {
    @ObservedObject var playerManager: VideoPlayerManager
    @ObservedObject var subtitleManager: SubtitleManager
    @State private var showControls = true
    @State private var controlsTimer: Timer?
    @State private var isDragging = false
    @State private var dragOffset: CGFloat = 0
    @State private var showSpeedOptions = false
    @State private var showAudioOptions = false
    @State private var showSubtitleOptions = false
    @State private var currentOrientation: UIDeviceOrientation = UIDevice.current.orientation
    
    let isFullscreen: Bool
    let onFullscreenToggle: () -> Void
    
    init(playerManager: VideoPlayerManager, subtitleManager: SubtitleManager, isFullscreen: Bool = false, onFullscreenToggle: @escaping () -> Void = {}) {
        self.playerManager = playerManager
        self.subtitleManager = subtitleManager
        self.isFullscreen = isFullscreen
        self.onFullscreenToggle = onFullscreenToggle
    }
    
    var body: some View {
        ZStack {
            // Video Layer
            if let player = playerManager.player {
                VideoPlayerLayer(player: player)
                    .onTapGesture {
                        toggleControls()
                    }
            } else {
                Color.black
                    .overlay(
                        VStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.5)
                            Text("Loading...")
                                .foregroundColor(.white)
                                .padding(.top, 8)
                        }
                    )
            }
            
            // Controls Overlay
            if showControls {
                controlsOverlay
                    .animation(.easeInOut(duration: 0.3), value: showControls)
            }
            
            // Subtitle Overlay
            SubtitleOverlayView(subtitleManager: subtitleManager)
        }
        .background(Color.black)
        .screenProtected()
        .onAppear {
            showControls = true
            startControlsTimer()
            playerManager.enableAirPlay()
        }
        .onDisappear {
            controlsTimer?.invalidate()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("PauseAllVideoPlayers"))) { _ in
            playerManager.pause()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            currentOrientation = UIDevice.current.orientation
        }
        .onReceive(playerManager.$currentTime) { currentTime in
            subtitleManager.updateCurrentTime(currentTime)
        }
    }
    
    private var controlsOverlay: some View {
        VStack {
            // Top Controls - Using orientation-aware version
            if isFullscreen {
                orientationAwareTopControls
            } else {
                // Inline mode: Custom positioned buttons
                VStack {
                    HStack {
                        // Fullscreen button - positioned at very top left
                        Button(action: onFullscreenToggle) {
                            Image(systemName: "arrow.up.left.and.arrow.down.right")
                                .font(.title2)
                                .padding(8)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        // Volume button - positioned at very top right
                        Button(action: {
                            if playerManager.volume > 0 {
                                playerManager.setVolume(0)
                            } else {
                                playerManager.setVolume(0.3)
                            }
                        }) {
                            Image(systemName: playerManager.volume > 0 ? "speaker.wave.2.fill" : "speaker.slash.fill")
                                .font(.title2)
                                .padding(8)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    
                    Spacer()
                }
            }
            
            Spacer()
            
            // Center Controls
            centerControls
            
            Spacer()
            
            // Bottom Controls
            bottomControls
        }
        .padding(isFullscreen ? .all : .bottom) // Only bottom padding for inline mode
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(0.7), Color.clear, Color.black.opacity(0.7)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    private var orientationAwareTopControls: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            
            HStack(spacing: 0) {
                // Left controls
                HStack(spacing: 12) {
                    if isFullscreen {
                        Button(action: onFullscreenToggle) {
                            Image(systemName: "xmark")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                        }
                    } else {
                        // Fullscreen button for inline mode - positioned on left
                        Button(action: onFullscreenToggle) {
                            Image(systemName: "arrow.up.left.and.arrow.down.right")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                        }
                    }
                    
                    // In landscape, group close with other controls to save space
                    if isFullscreen && isLandscape {
                        Button(action: {
                            // TODO: Implement PiP functionality
                        }) {
                            Image(systemName: "pip.enter")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                        }
                    }
                }
                .padding(.leading, isLandscape ? 40 : 16)
                
                Spacer()
                
                // Right controls - adapt based on orientation
                if isLandscape {
                    // Landscape: Stack vertically to save horizontal space
                    VStack(spacing: 4) {
                        if isFullscreen {
                            HStack(spacing: 6) {
                                Button(action: {
                                    if playerManager.volume > 0 {
                                        playerManager.setVolume(0)
                                    } else {
                                        playerManager.setVolume(0.5)
                                    }
                                }) {
                                    Image(systemName: playerManager.volume > 0 ? "speaker.wave.2.fill" : "speaker.slash.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white)
                                        .frame(width: 36, height: 36)
                                }
                                
                                Button(action: {}) {
                                    AVRoutePickerViewWrapper()
                                        .frame(width: 36, height: 36)
                                }
                            }
                            
                            // Volume slider below in landscape
                            Slider(value: Binding(
                                get: { playerManager.volume },
                                set: { playerManager.setVolume($0) }
                            ), in: 0...1)
                            .frame(width: 80)
                            .accentColor(.white)
                        }
                    }
                    .padding(.trailing, 40)
                } else {
                    // Portrait: Horizontal layout
                    HStack(spacing: 8) {
                        if isFullscreen {
                            Slider(value: Binding(
                                get: { playerManager.volume },
                                set: { playerManager.setVolume($0) }
                            ), in: 0...1)
                            .frame(width: 60)
                            .accentColor(.white)
                            
                            Button(action: {
                                if playerManager.volume > 0 {
                                    playerManager.setVolume(0)
                                } else {
                                    playerManager.setVolume(0.5)
                                }
                            }) {
                                Image(systemName: playerManager.volume > 0 ? "speaker.wave.2.fill" : "speaker.slash.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                            }
                            
                            Button(action: {}) {
                                AVRoutePickerViewWrapper()
                                    .frame(width: 40, height: 40)
                            }
                        } else {
                            // Volume control for inline mode - positioned on right
                            Button(action: {
                                if playerManager.volume > 0 {
                                    playerManager.setVolume(0)
                                } else {
                                    playerManager.setVolume(0.3) // Restore to inline volume
                                }
                            }) {
                                Image(systemName: playerManager.volume > 0 ? "speaker.wave.2.fill" : "speaker.slash.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                            }
                        }
                    }
                    .padding(.trailing, 20)
                }
            }
        }
        .frame(height: 60)
    }
    
    private var centerControls: some View {
        HStack(spacing: 60) {
            // Skip Backward
            Button(action: { playerManager.skipBackward() }) {
                Image(systemName: "gobackward.10")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            .scaleEffect(1.0)
            .animation(.easeInOut(duration: 0.1), value: playerManager.isPlaying)
            
            // Play/Pause/Replay
            Button(action: { playerManager.togglePlayPause() }) {
                Image(systemName: getPlayButtonIcon())
                    .font(.system(size: 50))
                    .foregroundColor(.white)
            }
            .scaleEffect(1.0)
            .animation(.easeInOut(duration: 0.1), value: playerManager.isPlaying)
            
            // Skip Forward
            Button(action: { playerManager.skipForward() }) {
                Image(systemName: "goforward.10")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            .scaleEffect(1.0)
            .animation(.easeInOut(duration: 0.1), value: playerManager.isPlaying)
        }
    }
    
    private var bottomControls: some View {
        VStack(spacing: 12) {
            // Progress Bar
            progressBar
            
            // Time and Additional Controls
            HStack {
                // Current Time
                Text(formatTime(playerManager.currentTime))
                    .font(.system(size: 14, weight: .regular, design: .monospaced))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Additional Controls (only in fullscreen)
                if isFullscreen {
                    additionalControls
                }
                
                Spacer()
                
                // Remaining Time
                Text("-\(formatTime(playerManager.duration - playerManager.currentTime))")
                    .font(.system(size: 14, weight: .regular, design: .monospaced))
                    .foregroundColor(.white)
            }
        }
    }
    
    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(height: 4)
                
                // Progress
                Rectangle()
                    .fill(Color.white)
                    .frame(width: progressWidth(geometry.size.width), height: 4)
                
                // Scrubber
                Circle()
                    .fill(Color.white)
                    .frame(width: 12, height: 12)
                    .offset(x: progressWidth(geometry.size.width) - 6)
                    .opacity(isDragging ? 1 : 0)
                    .animation(.easeInOut(duration: 0.2), value: isDragging)
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if !isDragging {
                            isDragging = true
                            controlsTimer?.invalidate()
                        }
                        let percentage = value.location.x / geometry.size.width
                        let newTime = max(0, min(playerManager.duration, playerManager.duration * percentage))
                        playerManager.seek(to: newTime)
                    }
                    .onEnded { _ in
                        isDragging = false
                        startControlsTimer()
                    }
            )
        }
        .frame(height: 20)
    }
    
    private var additionalControls: some View {
        HStack(spacing: 20) {
            // Speed Control
            Button(action: { showSpeedOptions.toggle() }) {
                Image(systemName: "speedometer")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
            }
            .popover(isPresented: $showSpeedOptions) {
                speedOptionsView
            }
            
            // Audio Options
            Button(action: { showAudioOptions.toggle() }) {
                Image(systemName: "waveform.circle")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
            }
            .popover(isPresented: $showAudioOptions) {
                audioOptionsView
            }
            
            // Caption Options
            Button(action: { showSubtitleOptions.toggle() }) {
                Image(systemName: subtitleManager.isSubtitlesEnabled ? "captions.bubble.fill" : "captions.bubble")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
            }
            .popover(isPresented: $showSubtitleOptions) {
                SubtitleControlsView(subtitleManager: subtitleManager)
            }
        }
    }
    
    private var speedOptionsView: some View {
        VStack(spacing: 8) {
            Text("Playback Speed")
                .font(.headline)
                .padding(.bottom, 4)
            
            ForEach([0.5, 0.75, 1.0, 1.25, 1.5, 2.0], id: \.self) { speed in
                Button(action: {
                    playerManager.setPlaybackRate(Float(speed))
                    showSpeedOptions = false
                }) {
                    HStack {
                        Text("\(speed, specifier: "%.2g")x")
                        Spacer()
                        if abs(playerManager.playbackRate - Float(speed)) < 0.01 {
                            Image(systemName: "checkmark")
                        }
                    }
                    .padding(.horizontal)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .frame(width: 120)
    }
    
    private var audioOptionsView: some View {
        VStack(spacing: 8) {
            Text("Audio Options")
                .font(.headline)
                .padding(.bottom, 4)
            
            Text("Audio tracks will be")
            Text("available here")
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 120)
    }
    
    private func toggleControls() {
        withAnimation(.easeInOut(duration: 0.3)) {
            showControls.toggle()
        }
        
        if showControls {
            startControlsTimer()
        } else {
            controlsTimer?.invalidate()
        }
    }
    
    private func startControlsTimer() {
        controlsTimer?.invalidate()
        controlsTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                showControls = false
            }
        }
    }
    
    private func progressWidth(_ totalWidth: CGFloat) -> CGFloat {
        guard playerManager.duration > 0 else { return 0 }
        return totalWidth * CGFloat(playerManager.currentTime / playerManager.duration)
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func getPlayButtonIcon() -> String {
        if playerManager.hasReachedEnd {
            return "arrow.counterclockwise" // Replay icon
        } else if playerManager.isPlaying {
            return "pause.fill"
        } else {
            return "play.fill"
        }
    }
}

// MARK: - AVRoutePickerView Wrapper
struct AVRoutePickerViewWrapper: UIViewRepresentable {
    func makeUIView(context: Context) -> AVRoutePickerView {
        let routePickerView = AVRoutePickerView()
        routePickerView.backgroundColor = UIColor.clear
        routePickerView.activeTintColor = UIColor.white
        routePickerView.tintColor = UIColor.white
        return routePickerView
    }
    
    func updateUIView(_ uiView: AVRoutePickerView, context: Context) {
        // No updates needed
    }
}

struct VideoPlayerLayer: UIViewRepresentable {
    let player: AVPlayer
    
    func makeUIView(context: Context) -> PlayerUIView {
        let view = PlayerUIView()
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspect
        playerLayer.backgroundColor = UIColor.clear.cgColor
        view.layer.addSublayer(playerLayer)
        view.playerLayer = playerLayer
        view.backgroundColor = .black
        
        return view
    }
    
    func updateUIView(_ uiView: PlayerUIView, context: Context) {
        uiView.playerLayer?.player = player
        
        // Force immediate frame update for orientation changes
        DispatchQueue.main.async {
            uiView.setNeedsLayout()
            uiView.layoutIfNeeded()
        }
    }
}

class PlayerUIView: UIView {
    var playerLayer: AVPlayerLayer?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }
}
