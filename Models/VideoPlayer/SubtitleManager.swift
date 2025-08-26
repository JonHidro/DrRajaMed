import SwiftUI
import AVFoundation

// MARK: - Subtitle Models
struct SubtitleSegment {
    let id = UUID()
    let startTime: TimeInterval
    let endTime: TimeInterval
    let text: String
}

struct SubtitleTrack {
    let language: String
    let segments: [SubtitleSegment]
}

// MARK: - Subtitle Manager
class SubtitleManager: ObservableObject {
    @Published var currentSubtitle: String = ""
    @Published var isSubtitlesEnabled = false
    @Published var availableTracks: [SubtitleTrack] = []
    @Published var selectedTrack: SubtitleTrack?
    
    private var currentTime: TimeInterval = 0
    
    init() {
        // Start with empty tracks - will be populated when loading actual SRT files
        availableTracks = []
        selectedTrack = nil
    }
    
    func updateCurrentTime(_ time: TimeInterval) {
        currentTime = time
        updateCurrentSubtitle()
    }
    
    func enableSubtitles(_ enabled: Bool) {
        isSubtitlesEnabled = enabled
        if !enabled {
            currentSubtitle = ""
        } else {
            updateCurrentSubtitle()
        }
    }
    
    func selectTrack(_ track: SubtitleTrack?) {
        selectedTrack = track
        updateCurrentSubtitle()
    }
    
    func clearSubtitles() {
        availableTracks = []
        selectedTrack = nil
        currentSubtitle = ""
    }
    
    func loadSubtitleTrack(_ track: SubtitleTrack) {
        // Clear existing tracks and add the new one
        availableTracks = [track]
        selectedTrack = track
        updateCurrentSubtitle()
    }
    
    private func updateCurrentSubtitle() {
        guard isSubtitlesEnabled,
              let track = selectedTrack else {
            currentSubtitle = ""
            return
        }
        
        // Find the current subtitle segment
        let currentSegment = track.segments.first { segment in
            currentTime >= segment.startTime && currentTime <= segment.endTime
        }
        
        currentSubtitle = currentSegment?.text ?? ""
    }
    
    // MARK: - Parse SRT content
    func parseSRT(content: String) -> [SubtitleSegment] {
        var segments: [SubtitleSegment] = []
        let blocks = content.components(separatedBy: "\n\n")
        
        for block in blocks {
            let lines = block.components(separatedBy: "\n").filter { !$0.isEmpty }
            guard lines.count >= 3 else { continue }
            
            // Parse timing line (format: 00:00:01,000 --> 00:00:04,000)
            let timingLine = lines[1]
            let timingComponents = timingLine.components(separatedBy: " --> ")
            guard timingComponents.count == 2 else { continue }
            
            let startTime = parseTimeString(timingComponents[0])
            let endTime = parseTimeString(timingComponents[1])
            
            // Join text lines (everything after the timing line)
            let text = Array(lines[2...]).joined(separator: " ")
            
            if startTime >= 0 && endTime >= 0 {
                segments.append(SubtitleSegment(
                    startTime: startTime,
                    endTime: endTime,
                    text: text
                ))
            }
        }
        
        return segments.sorted { $0.startTime < $1.startTime }
    }
    
    private func parseTimeString(_ timeString: String) -> TimeInterval {
        // Parse format: 00:00:01,000 or 00:00:01.000
        let cleanTimeString = timeString.replacingOccurrences(of: ",", with: ".")
        let components = cleanTimeString.components(separatedBy: ":")
        guard components.count == 3 else { return -1 }
        
        let hours = Double(components[0]) ?? 0
        let minutes = Double(components[1]) ?? 0
        let seconds = Double(components[2]) ?? 0
        
        return hours * 3600 + minutes * 60 + seconds
    }
}

// MARK: - Subtitle Overlay View
struct SubtitleOverlayView: View {
    @ObservedObject var subtitleManager: SubtitleManager
    
    var body: some View {
        VStack {
            Spacer()
            
            if subtitleManager.isSubtitlesEnabled && !subtitleManager.currentSubtitle.isEmpty {
                Text(subtitleManager.currentSubtitle)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.black.opacity(0.8))
                    )
                    .padding(.horizontal, 40)
                    .padding(.bottom, 60) // Above bottom controls
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: subtitleManager.currentSubtitle)
            }
        }
    }
}

// MARK: - Subtitle Controls View
struct SubtitleControlsView: View {
    @ObservedObject var subtitleManager: SubtitleManager
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Subtitles")
                .font(.headline)
                .padding(.bottom)
            
            // Enable/Disable Toggle
            HStack {
                Text("Enable Subtitles")
                Spacer()
                Toggle("", isOn: $subtitleManager.isSubtitlesEnabled)
            }
            
            if subtitleManager.isSubtitlesEnabled && !subtitleManager.availableTracks.isEmpty {
                Divider()
                
                // Language Selection
                Text("Language")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                ForEach(subtitleManager.availableTracks, id: \.language) { track in
                    Button(action: {
                        subtitleManager.selectTrack(track)
                    }) {
                        HStack {
                            Text(track.language)
                            Spacer()
                            if subtitleManager.selectedTrack?.language == track.language {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
            } else if subtitleManager.isSubtitlesEnabled {
                Text("No subtitles available")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(width: 200)
    }
}
