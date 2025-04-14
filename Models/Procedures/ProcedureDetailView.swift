//
//  ProcedureDetailView.swift
//  DrRaja Prototype #3
//
//  Created by Jonathan Hidrogo on 3/25/25.
//

import SwiftUI
import AVKit
import FirebaseStorage

// MARK: – Layout Constants
private enum Layout {
    static let headerHeight: CGFloat = 120
    static let videoHeight: CGFloat  = 220
}

struct ProcedureDetailView: View {
    let procedure: ProcedureModel

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var favorites: FavoritesManager
    @Environment(\.colorScheme) var colorScheme

    @State private var subtitleIndex = 0
    @State private var pickerSteps: [String: Int] = [:]
    @State private var isFavoritedLocal = false
    @State private var videoURL: URL?

    private var isFavorited: Bool {
        favorites.procedures.contains { $0.id == procedure.id }
    }

    var body: some View {
        // Removed the inner NavigationStack if this view is already pushed inside one
        ScrollView {
            VStack(spacing: 20) {
                headerView
                videoSection
                subtitleNavigation
                stepPicker
                Text(infoForCurrentStep())
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.top)
            .padding(.bottom, 40) // Provides space above the tab bar
        }
        .toolbar(.visible, for: .tabBar) // Keeps the native tab bar showing
        .navigationTitle(procedure.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Ensure that the pickerSteps dictionary is initialized for the current subtitle
            pickerSteps[procedure.subtitles[subtitleIndex]] = 0
            isFavoritedLocal = isFavorited
            fetchVideoURL()
        }
    }
}

// MARK: – Header
private extension ProcedureDetailView {
    var headerView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [Color.blue, Color.purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: Layout.headerHeight)
                .padding(.horizontal)

            HStack {
                Text(procedure.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Spacer()

                HStack(spacing: 16) {
                    Button {
                        isFavoritedLocal.toggle()
                        if isFavoritedLocal {
                            favorites.procedures.append(procedure)
                        } else {
                            favorites.procedures.removeAll { $0.id == procedure.id }
                        }
                    } label: {
                        Image(systemName: isFavoritedLocal ? "heart.fill" : "heart")
                    }

                    Button(action: takeNotes) {
                        Image(systemName: "pencil")
                    }

                    Button(action: openChat) {
                        Image(systemName: "message")
                    }
                }
                .font(.title3)
                .foregroundColor(.white)
            }
            .padding(.horizontal, 24)
        }
    }

    var videoSection: some View {
        Group {
            if let url = videoURL {
                VideoPlayer(player: AVPlayer(url: url))
                    .frame(height: Layout.videoHeight)
                    .cornerRadius(12)
                    .padding(.horizontal)
            } else {
                ProgressView("Loading video…")
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
        .frame(height: 150)
        .padding(.horizontal)
        .onChange(of: pickerSteps[procedure.subtitles[subtitleIndex]] ?? 0) { _ in
            fetchVideoURL()
        }
    }
}

// MARK: – Actions & Helpers
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
        return "Information about Step \(step) for \(procedure.subtitles[subtitleIndex]) in \(procedure.name)."
    }

    func takeNotes() {
        // TODO: Implement note taking functionality.
    }

    func openChat() {
        // TODO: Implement chat functionality.
    }
}
