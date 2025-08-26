import SwiftUI
import AVKit

struct FullscreenPlayerViewAlternative: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var playerManager: VideoPlayerManager
    @ObservedObject var subtitleManager: SubtitleManager
    
    var body: some View {
        CustomVideoPlayerView(
            playerManager: playerManager,
            subtitleManager: subtitleManager,
            isFullscreen: true,
            onFullscreenToggle: {
                dismiss()
            }
        )
        .ignoresSafeArea()
        .statusBarHidden()
        .onAppear {
            // Don't seek to beginning - maintain current position
            // Just ensure it's playing if it should be
            if !playerManager.isPlaying && !playerManager.hasReachedEnd {
                playerManager.play()
            }
        }
        .onDisappear {
            playerManager.pause()
        }
    }
}
