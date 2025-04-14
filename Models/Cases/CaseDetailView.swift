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
    static let headerHeight: CGFloat = 120
    static let videoHeight: CGFloat  = 220
}

struct CaseDetailView: View {
    let caseItem: CaseModel

    // MARK: – Environment & State
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var favorites: FavoritesManager
    @Environment(\.colorScheme) private var colorScheme

    @State private var tagIndex         = 0
    @State private var stepIndex        = 0
    @State private var isFavoritedLocal = false
    @State private var videoURL: URL?

    private var isFavorited: Bool {
        favorites.cases.contains { $0.id == caseItem.id }
    }

    var body: some View {
        VStack(spacing: 0) {
            headerView

            ScrollView {
                VStack(spacing: 20) {
                    videoSection
                    subtitleNavigation
                    stepPicker

                    Text(infoForCurrentStep())
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 20)
                .padding(.bottom, 100) // ensures content clears bottom nav
            }
        }
        .edgesIgnoringSafeArea(.top) // lets header flush with device top
        .onAppear {
            isFavoritedLocal = isFavorited
            stepIndex = 0
            fetchVideoURL()
        }
    }
}

// MARK: – Subviews
private extension CaseDetailView {
    var headerView: some View {
        ZStack(alignment: .top) {
            RadialGradient(
                gradient: Gradient(colors: [Color.blue, Color.purple]),
                center: .topLeading,
                startRadius: 50,
                endRadius: 400
            )
            .frame(height: Layout.headerHeight)
            .ignoresSafeArea(edges: .top)

            HStack {
                // Back button
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                .accessibilityLabel("Back")

                Text(caseItem.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .padding(.leading, 8)

                Spacer()

                HStack(spacing: 16) {
                    Button {
                        isFavoritedLocal.toggle()
                        if isFavoritedLocal {
                            favorites.cases.append(caseItem)
                        } else {
                            favorites.cases.removeAll { $0.id == caseItem.id }
                        }
                    } label: {
                        Image(systemName: isFavoritedLocal ? "heart.fill" : "heart")
                            .font(.title2)
                    }

                    Button(action: takeNotes) {
                        Image(systemName: "pencil")
                            .font(.title2)
                    }

                    Button(action: openChat) {
                        Image(systemName: "message")
                            .font(.title2)
                    }
                }
                .foregroundColor(.white)
            }
            .padding(.top, 45)
            .padding(.horizontal)
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
                    .font(.title2)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .opacity(tagIndex > 0 ? 1 : 0.3)
            }

            Spacer()

            Text(caseItem.subtitles[tagIndex])
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(colorScheme == .dark ? .white : .black)

            Spacer()

            Button(action: navigateRight) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .opacity(tagIndex < caseItem.subtitles.count - 1 ? 1 : 0.3)
            }
        }
        .padding(.horizontal, 20)
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
        .frame(height: 150)
        .padding(.horizontal, 20)
        .onChange(of: stepIndex) { _ in
            fetchVideoURL()
        }
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
        return "Information about Step \(step) for \(tag) in \(caseItem.title)."
    }

    func takeNotes() {
        // TODO: Implement note-taking functionality.
    }

    func openChat() {
        // TODO: Implement chat functionality.
    }
}

// MARK: – Preview
struct CaseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CaseDetailView(caseItem: CaseModel.sample1)
            .environmentObject(FavoritesManager())
    }
}
