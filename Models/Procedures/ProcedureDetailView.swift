//
//  ProcedureDetailView.swift
//  DrRaja Prototype #3
//
//  Created by Jonathan Hidrogo on 3/25/25.
//

import SwiftUI
import AVKit
import FirebaseStorage

private enum Layout {
    static let headerHeight: CGFloat = 100
    static let videoHeight: CGFloat = 220
    static let infoBoxCollapsedHeight: CGFloat = 100
    static let infoBoxExpandedHeight: CGFloat = 200
}

struct ProcedureDetailView: View {
    let procedure: ProcedureModel

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var favorites: FavoritesManager
    @EnvironmentObject private var navigationManager: NavigationManager
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme

    @State private var subtitleIndex = 0
    @State private var pickerSteps: [String: Int] = [:]
    @State private var isFavoritedLocal = false
    @State private var videoURL: URL?
    @State private var isInfoExpanded: Bool = false
    @State private var showNotes = false

    private var isFavorited: Bool {
        favorites.procedures.contains { $0.id == procedure.id }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                ZStack(alignment: .bottomLeading) {
                    RadialGradient(
                        gradient: Gradient(colors: [Color.orange, Color.red]),
                        center: .topLeading,
                        startRadius: 50,
                        endRadius: 400
                    )
                    .ignoresSafeArea(edges: .top)
                    .frame(height: Layout.headerHeight)

                    Text(procedure.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.leading, 16)
                        .padding(.bottom, 1)
                }

                ScrollView {
                    VStack(spacing: 16) {
                        videoSection
                        subtitleNavigation
                        infoBox
                        stepPicker
                        actionButtonsView
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 60)
                }
            }

            BottomNavBar(selectedTab: $appState.selectedTab) { newTab in
                navigationManager.goToRoot()
            }
        }
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.top)
        .environment(\.colorScheme, themeManager.isDarkMode ? .dark : .light)
        .onAppear {
            pickerSteps[procedure.subtitles[subtitleIndex]] = 0
            isFavoritedLocal = isFavorited
            fetchVideoURL()
        }
        .sheet(isPresented: $showNotes) {
            let subtitle = procedure.subtitles[subtitleIndex]
            let step = pickerSteps[subtitle] ?? 0
            let noteKey = "notes_\(procedure.name)_\(subtitle)_step\(step)"
            NoteTakingView(noteKey: noteKey)
        }
    }
}

private extension ProcedureDetailView {
    var videoSection: some View {
        Group {
            if let url = videoURL {
                VideoPlayer(player: AVPlayer(url: url))
                    .frame(height: Layout.videoHeight)
                    .cornerRadius(12)
                    .padding(.horizontal)
            } else {
                ProgressView("Loading video...")
                    .frame(height: Layout.videoHeight)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
            }
        }
    }

    var subtitleNavigation: some View {
        HStack {
            Button(action: navigateLeft) {
                Image(systemName: "chevron.left")
                    .opacity(subtitleIndex > 0 ? 1 : 0.3)
            }

            Spacer()

            Text(procedure.subtitles[subtitleIndex])
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(colorScheme == .dark ? .white : .primary)

            Spacer()

            Button(action: navigateRight) {
                Image(systemName: "chevron.right")
                    .opacity(subtitleIndex < procedure.subtitles.count - 1 ? 1 : 0.3)
            }
        }
        .font(.title2)
        .padding(.horizontal, 30)
    }

    var infoBox: some View {
        VStack(alignment: .leading, spacing: 0) {
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
        Picker("Steps", selection: Binding(
            get: { pickerSteps[procedure.subtitles[subtitleIndex]] ?? 0 },
            set: { pickerSteps[procedure.subtitles[subtitleIndex]] = $0 }
        )) {
            let key = procedure.subtitles[subtitleIndex]
            let count = procedure.videoFilesBySubtitle[key]?.count ?? 0
            ForEach(0..<count, id: \.self) { idx in
                Text("Step \(idx + 1)").tag(idx)
            }
        }
        .pickerStyle(WheelPickerStyle())
        .frame(height: 120)
        .padding(.horizontal)
        .onChange(of: subtitleIndex) {
            fetchVideoURL()
        }
    }

    var actionButtonsView: some View {
        HStack(spacing: 40) {
            Button {
                isFavoritedLocal.toggle()
                if isFavoritedLocal {
                    favorites.procedures.append(procedure)
                } else {
                    favorites.procedures.removeAll { $0.id == procedure.id }
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

private extension ProcedureDetailView {
    func navigateLeft() {
        guard subtitleIndex > 0 else { return }
        subtitleIndex -= 1
        pickerSteps[procedure.subtitles[subtitleIndex]] = 0
        fetchVideoURL()
    }

    func navigateRight() {
        guard subtitleIndex < procedure.subtitles.count - 1 else { return }
        subtitleIndex += 1
        pickerSteps[procedure.subtitles[subtitleIndex]] = 0
        fetchVideoURL()
    }

    func fetchVideoURL() {
        let key = procedure.subtitles[subtitleIndex]
        guard
            let videos = procedure.videoFilesBySubtitle[key],
            let step = pickerSteps[key],
            step < videos.count
        else { return }

        let fileName = videos[step] + ".mp4"
        let path = "procedure_videos/\(procedure.name.lowercased())/\(key.lowercased())/\(fileName)"
        Storage.storage()
            .reference()
            .child(path)
            .downloadURL { url, _ in
                if let url = url { videoURL = url }
            }
    }

    func infoForCurrentStep() -> String {
        let step = (pickerSteps[procedure.subtitles[subtitleIndex]] ?? 0) + 1
        return "Information about Step \(step) for \(procedure.subtitles[subtitleIndex]) in \(procedure.name).\n\nThis is where the detailed explanation of the current step would go. This content can be scrolled if it exceeds the visible area of the box. The information might include instructions, warnings, tips, and other relevant details that would help the user understand and perform this specific procedure step correctly.\n\nAdditional paragraphs of information can provide more context or detail as needed."
    }

    func takeNotes() {
        showNotes = true
    }

    func openChat() {
        // TODO: Implement chat functionality.
    }
}
