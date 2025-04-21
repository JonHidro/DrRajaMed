//
//  CaseDetailView.swift
//  DrRaja Prototype #3
//
//  Created by Jonathan Hidrogo on 3/25/25.
//

import SwiftUI
import AVKit
import FirebaseStorage

// MARK: – Layout Constants
private enum Layout {
    static let headerHeight: CGFloat = 100
    static let videoHeight: CGFloat = 220
    static let infoBoxCollapsedHeight: CGFloat = 100
    static let infoBoxExpandedHeight: CGFloat = 200
}

struct CaseDetailView: View {
    let caseItem: CaseModel
    
    // MARK: – Environment & State
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var favorites: FavoritesManager
    @EnvironmentObject private var navigationManager: NavigationManager
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var themeManager: ThemeManager
    
    @State private var tagIndex = 0
    @State private var stepIndex = 0
    @State private var isFavoritedLocal = false
    @State private var videoURL: URL?
    @State private var isInfoExpanded: Bool = false
    
    private var isFavorited: Bool {
        favorites.cases.contains { $0.id == caseItem.id }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // Header with lowered title (matching NotificationsView)
                ZStack(alignment: .bottomLeading) {
                    RadialGradient(
                        gradient: Gradient(colors: [Color.orange, Color.red]),
                        center: .topLeading,
                        startRadius: 50,
                        endRadius: 400
                    )
                    .ignoresSafeArea(edges: .top)
                    .frame(height: Layout.headerHeight)
                    
                    Text(caseItem.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.leading, 16)
                        .padding(.bottom, 1)
                }
                
                // Main content in scrollable area
                ScrollView {
                    VStack(spacing: 16) {
                        videoSection
                        subtitleNavigation
                        
                        // Information box with expand/collapse option
                        infoBox
                        
                        // Step picker
                        stepPicker
                        
                        // Action buttons
                        actionButtonsView
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 60) // Extra space for tab bar
                }
            }
            
            // BottomNavBar
            BottomNavBar(selectedTab: $appState.selectedTab) { newTab in
                // Always clear navigation stack when any tab is tapped, especially home
                navigationManager.goToRoot()
            }
        }
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.top)
        .environment(\.colorScheme, themeManager.isDarkMode ? .dark : .light)
        .onAppear {
            isFavoritedLocal = isFavorited
            stepIndex = 0
            fetchVideoURL()
        }
    }
}

// MARK: – UI Components
private extension CaseDetailView {
    var videoSection: some View {
        Group {
            if let url = videoURL {
                VideoPlayer(player: AVPlayer(url: url))
                    .frame(height: Layout.videoHeight)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
            } else {
                ZStack {
                    Color(.systemGray6)
                        .frame(height: Layout.videoHeight)
                        .cornerRadius(12)
                    
                    VStack {
                        ProgressView()
                            .tint(.gray)
                        Text("Loading video...")
                            .foregroundColor(.gray)
                            .padding(.top, 8)
                    }
                }
                .padding(.horizontal)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
        }
    }
    
    var subtitleNavigation: some View {
        HStack {
            Button(action: navigateLeft) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .opacity(tagIndex > 0 ? 1 : 0.3)
            }
            
            Spacer()
            
            Text(caseItem.subtitles[tagIndex])
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(colorScheme == .dark ? .white : .primary)
            
            Spacer()
            
            Button(action: navigateRight) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .opacity(tagIndex < caseItem.subtitles.count - 1 ? 1 : 0.3)
            }
        }
        .padding(.horizontal, 30)
    }
    
    var infoBox: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with expand/collapse button
            HStack {
                Text("Step Information")
                    .font(.headline)
                    .padding(.leading)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isInfoExpanded.toggle()
                    }
                }) {
                    Image(systemName: isInfoExpanded ? "chevron.up" : "chevron.down")
                        .padding(8)
                        .background(Color(.systemGray5))
                        .clipShape(Circle())
                }
                .padding(.trailing)
            }
            .padding(.top, 8)
            
            // Scrollable info content
            ScrollView {
                Text(infoForCurrentStep())
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                    .padding(.top, 5)
            }
            .frame(height: isInfoExpanded ? Layout.infoBoxExpandedHeight : Layout.infoBoxCollapsedHeight)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .padding(.horizontal)
    }
    
    var stepPicker: some View {
        Picker("Steps", selection: $stepIndex) {
            let key = caseItem.subtitles[tagIndex]
            let count = caseItem.videoFilesBySubtitle[key]?.count ?? 0
            ForEach(0..<count, id: \.self) { idx in
                Text("Step \(idx + 1)").tag(idx)
            }
        }
        .pickerStyle(WheelPickerStyle())
        .frame(height: 120)
        .padding(.horizontal)
        .onChange(of: stepIndex) { oldValue, newValue in
            fetchVideoURL()
        }
    }
    
    var actionButtonsView: some View {
        HStack(spacing: 40) {
            Button {
                isFavoritedLocal.toggle()
                if isFavoritedLocal {
                    favorites.cases.append(caseItem)
                } else {
                    favorites.cases.removeAll { $0.id == caseItem.id }
                }
            } label: {
                VStack {
                    Image(systemName: isFavoritedLocal ? "heart.fill" : "heart")
                        .font(.title2)
                    Text("Favorite")
                        .font(.caption)
                }
            }
            .tint(.red)
            
            Button(action: takeNotes) {
                VStack {
                    Image(systemName: "pencil")
                        .font(.title2)
                    Text("Notes")
                        .font(.caption)
                }
            }
            .tint(.blue)
            
            Button(action: openChat) {
                VStack {
                    Image(systemName: "message")
                        .font(.title2)
                    Text("Chat")
                        .font(.caption)
                }
            }
            .tint(.green)
        }
        .padding(.vertical)
    }
}

// MARK: – Actions & Helpers
private extension CaseDetailView {
    func navigateLeft() {
        guard tagIndex > 0 else { return }
        tagIndex -= 1
        stepIndex = 0
        fetchVideoURL()
    }
    
    func navigateRight() {
        guard tagIndex < caseItem.subtitles.count - 1 else { return }
        tagIndex += 1
        stepIndex = 0
        fetchVideoURL()
    }
    
    func fetchVideoURL() {
        let key = caseItem.subtitles[tagIndex]
        guard let videos = caseItem.videoFilesBySubtitle[key], stepIndex < videos.count else { return }
        
        let fileName = videos[stepIndex] + ".mp4"
        let path = "case_videos/\(fileName)"
        Storage.storage()
            .reference()
            .child(path)
            .downloadURL { url, _ in
                if let url = url { videoURL = url }
            }
    }
    
    func infoForCurrentStep() -> String {
        let tag = caseItem.subtitles[tagIndex]
        let step = stepIndex + 1
        return "Information about Step \(step) for \(tag) in \(caseItem.title).\n\nThis is where the detailed explanation of the current step would go. This content can be scrolled if it exceeds the visible area of the box. The information might include instructions, warnings, tips, and other relevant details that would help the user understand and perform this specific procedure step correctly.\n\nAdditional paragraphs of information can provide more context or detail as needed."
    }
    
    func takeNotes() {
        // TODO: Implement note-taking functionality.
    }
    
    func openChat() {
        // TODO: Implement chat functionality.
    }
}
