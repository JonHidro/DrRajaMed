import SwiftUI
import AVKit
import FirebaseStorage

private enum Layout {
    static let headerHeight: CGFloat            = 100
    static let videoHeight: CGFloat             = 220
    static let infoBoxHeaderHeight: CGFloat     = 40
    static let infoBoxCollapsedHeight: CGFloat  = 250
    static let infoBoxExpandedHeight: CGFloat   = 410
    static let stepPickerHeight: CGFloat        = 90
    static let spacing: CGFloat                 = 8
}

struct CaseDetailView: View {
    let caseItem: CaseModel

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var favorites: FavoritesManager
    @EnvironmentObject private var navigationManager: NavigationManager
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme

    @State private var tagIndex = 0
    @State private var stepIndex = 0
    @State private var isFavoritedLocal = false
    @State private var videoURL: URL?
    @StateObject private var playerManager = VideoPlayerManager()
    @State private var subtitleManager = SubtitleManager()
    @State private var isFullScreen = false
    @State private var isInfoExpanded = false
    @State private var showNotes = false
    @State private var isVideoReady = false

    private var isFavorited: Bool {
        favorites.cases.contains { $0.id == caseItem.id }
    }

    var body: some View {
        ZStack(alignment: .top) {
            backgroundColor.edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                headerView

                ScrollView {
                    VStack(spacing: Layout.spacing) {
                        videoSection.padding(.top, Layout.spacing/2)
                        subtitleNavigation
                        infoBox.padding(.top, Layout.spacing/2)
                        stepPicker
                        actionButtonsView.padding(.top, Layout.spacing)
                    }
                    .padding(.bottom, 16)
                }
            }
            .edgesIgnoringSafeArea(.top)
        }
        .navigationBarHidden(true)
        .environment(\.colorScheme, themeManager.isDarkMode ? .dark : .light)
        .onAppear(perform: setupView)
        .onDisappear {
            playerManager.pause()
        }
        .sheet(isPresented: $showNotes) {
            let subtitle = caseItem.subtitles[tagIndex]
            let step = stepIndex
            let noteKey = "notes_\(caseItem.title)_\(subtitle)_step\(step)"
            NoteTakingView(noteKey: noteKey)
        }
        .fullScreenCover(isPresented: $isFullScreen) {
            FullscreenPlayerViewAlternative(
                playerManager: playerManager,
                subtitleManager: subtitleManager
            )
            .onAppear {
                // Keep current position and volume up for fullscreen
                playerManager.setVolume(1.0) // Full volume in fullscreen
                // Don't seek to 0 - maintain current position
                if !playerManager.isPlaying {
                    playerManager.play() // Only start playing if it was paused
                }
            }
            .onDisappear {
                // Keep the video position when returning to inline
                // Only adjust volume
                playerManager.setVolume(0.3) // Back to inline volume
            }
        }
    }
    
    // MARK: - View Components
    private var backgroundColor: Color {
        themeManager.isDarkMode ? .black : Color(.systemBackground)
    }

    private var headerView: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color.orange, Color.red]),
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(height: Layout.headerHeight)
        .overlay(
            HStack(spacing: 12) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.white)
                }

                Text(caseItem.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top ?? 44)
        )
    }

    private var videoSection: some View {
        ZStack(alignment: .topTrailing) {
            // Use CustomVideoPlayerView for the inline player
            if playerManager.player != nil {
                CustomVideoPlayerView(
                    playerManager: playerManager,
                    subtitleManager: subtitleManager,
                    isFullscreen: false,
                    onFullscreenToggle: {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            isFullScreen = true
                        }
                    }
                )
                .frame(height: Layout.videoHeight)
                .cornerRadius(12)
                .padding(.horizontal)
                .onAppear {
                    // Start with volume enabled but lower for inline view
                    playerManager.setVolume(0.3)
                    // Let the video load properly before playing
                    if isVideoReady {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            playerManager.play()
                        }
                    }
                }
            } else {
                ZStack {
                    Rectangle().fill(Color(.systemGray5))
                    ProgressView("Loading video...")
                }
                .frame(height: Layout.videoHeight)
                .cornerRadius(12)
                .padding(.horizontal)
            }

            // Fullscreen button overlay
            if videoURL != nil {
                Button {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        isFullScreen = true
                    }
                } label: {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.title2)
                        .padding(8)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Circle())
                        .foregroundColor(.white)
                }
                .padding(.top, 12)
                .padding(.trailing, 24)
            }
        }
        .frame(height: Layout.videoHeight)
    }

    private var subtitleNavigation: some View {
        HStack {
            Button(action: navigateLeft) {
                Image(systemName: "chevron.left")
                    .opacity(tagIndex > 0 ? 1 : 0.3)
            }
            Spacer()
            Text(caseItem.subtitles[tagIndex])
                .font(.headline)
                .fontWeight(.medium)
            Spacer()
            Button(action: navigateRight) {
                Image(systemName: "chevron.right")
                    .opacity(tagIndex < caseItem.subtitles.count - 1 ? 1 : 0.3)
            }
        }
        .font(.title2)
        .padding(.horizontal, 30)
        .foregroundColor(themeManager.isDarkMode ? .white : .black)
    }

    private var infoBox: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Step Information")
                    .font(.headline)
                    .padding(.leading)
                Spacer()
                Button {
                    withAnimation(.spring()) { isInfoExpanded.toggle() }
                } label: {
                    Image(systemName: isInfoExpanded ? "chevron.up" : "chevron.down")
                        .padding(8)
                        .background(Color(.systemGray5))
                        .clipShape(Circle())
                }
                .padding(.trailing)
            }
            .padding(.vertical, 8)
            .background(Color(.systemGray6))

            ScrollView {
                Text(infoForCurrentStep())
                    .font(.body)
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: isInfoExpanded
                   ? Layout.infoBoxExpandedHeight - Layout.infoBoxHeaderHeight
                   : Layout.infoBoxCollapsedHeight - Layout.infoBoxHeaderHeight)
        }
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
        .frame(height: isInfoExpanded
               ? Layout.infoBoxExpandedHeight
               : Layout.infoBoxCollapsedHeight)
        .shadow(radius: 2)
    }

    private var stepPicker: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .shadow(radius: 2)

            Picker("Steps", selection: $stepIndex) {
                let key = caseItem.subtitles[tagIndex]
                let count = caseItem.videoFilesBySubtitle[key]?.count ?? 0
                ForEach(0..<count, id: \.self) { idx in
                    Text("Step \(idx + 1)").tag(idx)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(height: Layout.stepPickerHeight)
        }
        .frame(height: Layout.stepPickerHeight)
        .padding(.horizontal)
        .onChange(of: tagIndex) { _ in
            stepIndex = 0
            fetchVideoURL()
        }
        .onChange(of: stepIndex) { _ in
            fetchVideoURL()
        }
    }

    private var actionButtonsView: some View {
        HStack(spacing: 40) {
            Button {
                isFavoritedLocal.toggle()
                if isFavoritedLocal {
                    favorites.cases.append(caseItem)
                } else {
                    favorites.cases.removeAll { $0.id == caseItem.id }
                }
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: isFavoritedLocal ? "heart.fill" : "heart")
                        .font(.title2)
                    Text("Favorite").font(.caption)
                }
            }
            .tint(.red)

            Button(action: takeNotes) {
                VStack(spacing: 4) {
                    Image(systemName: "pencil").font(.title2)
                    Text("Notes").font(.caption)
                }
            }
            .tint(.blue)

            Button(action: openChat) {
                VStack(spacing: 4) {
                    Image(systemName: "message").font(.title2)
                    Text("Chat").font(.caption)
                }
            }
            .tint(.green)
        }
    }
    
    // MARK: - Helper Methods
    private func navigateLeft() {
        guard tagIndex > 0 else { return }
        tagIndex -= 1
        stepIndex = 0
    }

    private func navigateRight() {
        guard tagIndex < caseItem.subtitles.count - 1 else { return }
        tagIndex += 1
        stepIndex = 0
    }

    private func setupView() {
        stepIndex = 0
        isFavoritedLocal = isFavorited
        fetchVideoURL()
    }

    private func fetchVideoURL() {
        let key = caseItem.subtitles[tagIndex]
        guard let videos = caseItem.videoFilesBySubtitle[key],
              stepIndex < videos.count else {
            print("Invalid subtitle or step. tagIndex: \(tagIndex), subtitle: \(key), stepIndex: \(stepIndex)")
            return
        }

        // Reset video and subtitle state
        videoURL = nil
        isVideoReady = false
        playerManager.pause()
        playerManager.cleanup()
        subtitleManager.clearSubtitles()

        let fileName = videos[stepIndex] + ".mp4"
        let caseName = caseItem.title.lowercased()
        let subtitleName = key.lowercased()
        let videoPath = "case_videos/\(caseName)/\(subtitleName)/\(fileName)"

        print("Fetching case video from path: \(videoPath)")

        Storage.storage()
            .reference()
            .child(videoPath)
            .downloadURL { url, error in
                if let error = error {
                    print("Firebase case video download error: \(error.localizedDescription)")
                } else if let url = url {
                    print("Got case video URL: \(url.absoluteString)")
                    DispatchQueue.main.async {
                        self.videoURL = url
                        self.playerManager.loadVideo(from: url)
                        
                        // Load subtitles for this video
                        self.loadSubtitlesForCurrentVideo(fileName: fileName, caseName: caseName, subtitleName: subtitleName)
                        
                        // Wait for player to be ready
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.isVideoReady = true
                            print("Case video loaded and ready to play from start")
                        }
                    }
                }
            }
    }
    
    private func loadSubtitlesForCurrentVideo(fileName: String, caseName: String, subtitleName: String) {
        // Create SRT filename from video filename
        let srtFileName = fileName.replacingOccurrences(of: ".mp4", with: ".srt")
        let srtPath = "case_subtitles/\(caseName)/\(subtitleName)/\(srtFileName)"
        
        print("Looking for case subtitle file at: \(srtPath)")
        
        Storage.storage()
            .reference()
            .child(srtPath)
            .downloadURL { url, error in
                if let url = url {
                    print("Found case subtitle file: \(url.absoluteString)")
                    
                    // Download the SRT content
                    URLSession.shared.dataTask(with: url) { data, response, error in
                        if let data = data, let srtContent = String(data: data, encoding: .utf8) {
                            print("Downloaded case SRT content, parsing...")
                            
                            DispatchQueue.main.async {
                                let segments = self.subtitleManager.parseSRT(content: srtContent)
                                let track = SubtitleTrack(language: "English", segments: segments)
                                
                                print("Parsed \(segments.count) case subtitle segments")
                                
                                // Load the subtitle track
                                self.subtitleManager.loadSubtitleTrack(track)
                            }
                        } else {
                            print("Failed to download or parse case SRT content")
                        }
                    }.resume()
                } else {
                    print("No case subtitle file found at: \(srtPath)")
                    if let error = error {
                        print("Case subtitle error: \(error.localizedDescription)")
                    }
                }
            }
    }

    private func infoForCurrentStep() -> String {
        let step = stepIndex + 1
        return """
        Information about Step \(step) for \(caseItem.subtitles[tagIndex]) in \(caseItem.title).

        This is where the detailed explanation of the current step would go. This content can be scrolled if it exceeds the visible area of the box. The information might include instructions, warnings, tips, and other relevant details that would help the user understand and perform this specific case step correctly.This is where the detailed explanation of the current step would go. This content can be scrolled if it exceeds the visible area of the box. The information might include instructions, warnings, tips, and other relevant details that would help the user understand and perform this specific case step correctly.The information might include instructions, warnings, tips, and other relevant details that would help the user understand and perform this specific case step correctly.
        """
    }

    private func takeNotes() {
        showNotes = true
    }

    private func openChat() {
        // TODO: Implement chat functionality
    }
}
