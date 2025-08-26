import SwiftUI
import AVKit
import Combine

class VideoPlayerManager: ObservableObject {
    @Published var player: AVPlayer?
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var volume: Float = 0.5
    @Published var playbackRate: Float = 1.0
    @Published var hasReachedEnd = false
    
    private var timeObserver: Any?
    private var cancellables = Set<AnyCancellable>()
    private var playerItemEndObserver: AnyCancellable?
    private var hasPerformedInitialSeek = false
    
    init() {
        setupAudioSession()
        print("VideoPlayerManager initialized")
    }
    
    deinit {
        cleanup()
        print("VideoPlayerManager deinitialized")
    }
    
    func setupPlayer(with url: URL) {
        cleanup()
        hasPerformedInitialSeek = false
        print("Setting up player with URL: \(url.absoluteString)")
        
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        print("Initial player time: \(player?.currentTime().seconds ?? 0)")
        player?.volume = volume
        player?.rate = 0
        hasReachedEnd = false
        currentTime = 0
        
        // Multiple seek attempts with detailed logging
        player?.seek(to: CMTime.zero, completionHandler: { completed in
            print("First seek completed: \(completed), time now: \(self.player?.currentTime().seconds ?? 0)")
        })
        
        // Wait for player to be ready, then seek again
        playerItem.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                print("Player status changed to: \(status)")
                if status == .readyToPlay {
                    print("Player ready, current time: \(self?.player?.currentTime().seconds ?? 0)")
                    self?.performAggressiveSeekToStart()
                }
            }
            .store(in: &cancellables)
        
        setupTimeObserver()
        observePlayerState()
        observePlayerItem()
        observePlayerItemEnd()
        enableAirPlay()
    }
    
    private func performAggressiveSeekToStart() {
        // Multiple seeks with delays to ensure it sticks
        player?.seek(to: CMTime.zero, completionHandler: { [weak self] completed in
            print("Ready-state seek completed: \(completed), final time: \(self?.player?.currentTime().seconds ?? 0)")
            
            // If still not at zero, try again after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let currentTime = self?.player?.currentTime().seconds, currentTime > 0.5 {
                    print("Still not at start (\(currentTime)s), attempting force seek...")
                    self?.forceSeekToStart()
                }
            }
        })
    }
    
    private func forceSeekToStart() {
        // Force seek with exact timing
        let exactZero = CMTime(value: 0, timescale: 600)
        player?.seek(to: exactZero, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] completed in
            print("Force seek completed: \(completed), time: \(self?.player?.currentTime().seconds ?? 0)")
            
            // Final check and additional attempt if needed
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let currentTime = self?.player?.currentTime().seconds, currentTime > 0.5 {
                    print("Final seek attempt for time: \(currentTime)")
                    self?.player?.seek(to: CMTime.zero)
                }
            }
        }
    }
    
    func loadVideo(from url: URL) {
        print("Loading video from URL: \(url.absoluteString)")
        setupPlayer(with: url)
    }
    
    func play() {
        guard let player = player else { return }
        
        // If we haven't done the initial seek and we're not at the start, seek first
        if !hasPerformedInitialSeek && player.currentTime().seconds > 0.5 {
            print("Play called but not at start, seeking first...")
            hasPerformedInitialSeek = true
            player.seek(to: CMTime.zero) { [weak self] completed in
                if completed {
                    self?.actuallyPlay()
                }
            }
            return
        }
        
        actuallyPlay()
    }
    
    private func actuallyPlay() {
        guard let player = player else { return }
        
        if hasReachedEnd {
            restart()
            return
        }
        
        player.play()
        player.rate = playbackRate
        isPlaying = true
        print("Playing video, current rate: \(player.rate)")
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
        print("Paused video")
    }
    
    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    func seek(to time: TimeInterval) {
        guard let player = player else { return }
        
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        let wasPlaying = isPlaying
        
        pause()
        
        player.seek(to: cmTime, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] completed in
            DispatchQueue.main.async {
                if completed {
                    if time < (self?.duration ?? 0) - 1.0 {
                        self?.hasReachedEnd = false
                    }
                    
                    if wasPlaying {
                        self?.actuallyPlay()
                    }
                    print("Seek completed to \(time) seconds")
                }
            }
        }
    }
    
    func restart() {
        hasReachedEnd = false
        hasPerformedInitialSeek = false
        currentTime = 0
        
        // Force seek to start with aggressive method
        let exactZero = CMTime(value: 0, timescale: 600)
        player?.seek(to: exactZero, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] completed in
            print("Restart seek completed: \(completed), time: \(self?.player?.currentTime().seconds ?? 0)")
            
            // Additional check to ensure we're at the start
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let currentTime = self?.player?.currentTime().seconds, currentTime > 0.5 {
                    print("Restart not at start, forcing seek again...")
                    self?.player?.seek(to: CMTime.zero) { _ in
                        self?.actuallyPlay()
                    }
                } else {
                    self?.actuallyPlay()
                }
            }
        }
        
        print("Video restarted")
    }
    
    func skipForward(_ seconds: Double = 10) {
        let currentTime = player?.currentTime() ?? CMTime.zero
        let newTime = CMTimeAdd(currentTime, CMTime(seconds: seconds, preferredTimescale: 600))
        let newTimeSeconds = min(newTime.seconds, duration)
        seek(to: newTimeSeconds)
        print("Skipped forward to \(newTimeSeconds) seconds")
    }
    
    func skipBackward(_ seconds: Double = 10) {
        let currentTime = player?.currentTime() ?? CMTime.zero
        let newTime = CMTimeSubtract(currentTime, CMTime(seconds: seconds, preferredTimescale: 600))
        let newTimeSeconds = max(newTime.seconds, 0)
        seek(to: newTimeSeconds)
        print("Skipped backward to \(newTimeSeconds) seconds")
    }
    
    func setVolume(_ volume: Float) {
        self.volume = volume
        player?.volume = volume
        print("Volume set to \(volume)")
        
        // Force UI update by triggering objectWillChange
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    func setPlaybackRate(_ rate: Float) {
        self.playbackRate = rate
        if isPlaying {
            player?.rate = rate
        }
        print("Playback rate set to \(rate)")
    }
    
    func enableAirPlay() {
        player?.allowsExternalPlayback = true
        player?.usesExternalPlaybackWhileExternalScreenIsActive = true
        print("AirPlay enabled")
    }
    
    func cleanup() {
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
        
        playerItemEndObserver?.cancel()
        
        player?.pause()
        player = nil
        isPlaying = false
        currentTime = 0
        duration = 0
        hasReachedEnd = false
        hasPerformedInitialSeek = false
        cancellables.removeAll()
        print("Player cleaned up")
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    private func setupTimeObserver() {
        let interval = CMTime(seconds: 0.1, preferredTimescale: 600)
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.currentTime = time.seconds
        }
    }
    
    private func observePlayerState() {
        player?.publisher(for: \.rate)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] rate in
                self?.isPlaying = rate > 0
            }
            .store(in: &cancellables)
    }
    
    private func observePlayerItem() {
        player?.currentItem?.publisher(for: \.duration)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] duration in
                if duration.isNumeric {
                    self?.duration = duration.seconds
                }
            }
            .store(in: &cancellables)
    }
    
    private func observePlayerItemEnd() {
        playerItemEndObserver = NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                if notification.object as? AVPlayerItem == self?.player?.currentItem {
                    self?.hasReachedEnd = true
                    self?.isPlaying = false
                }
            }
    }
}
