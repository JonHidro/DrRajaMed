//
//  ProcedureModel.swift
//  DrRaja Prototype #3
//
//  Created by Jonathan Hidrogo on 3/25/25.
//

import Foundation
import FirebaseStorage

struct ProcedureModel: Identifiable, Hashable, Codable {
    let id: UUID
    let name: String
    let description: String
    let imageName: String

    let cardTags: [String]
    let subtitles: [String]
    let videoFilesBySubtitle: [String: [String]]

    init(
        id: UUID = .init(),
        name: String,
        description: String,
        imageName: String,
        cardTags: [String] = [],
        subtitles: [String] = [],
        videoFilesBySubtitle: [String: [String]] = [:]
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.imageName = imageName
        self.cardTags = cardTags
        self.subtitles = subtitles
        self.videoFilesBySubtitle = videoFilesBySubtitle
    }

    var availableSubtitles: [String] {
        subtitles.filter { videoFilesBySubtitle[$0] != nil }
    }
}

extension ProcedureModel {
    /// Firebase video URL fetcher (optional convenience function)
    func fetchVideoURL(
        subtitleIndex: Int,
        stepIndex: Int,
        completion: @escaping (URL?) -> Void
    ) {
        guard
            subtitleIndex < subtitles.count,
            let videos = videoFilesBySubtitle[subtitles[subtitleIndex]],
            stepIndex < videos.count
        else {
            print("❌ Invalid subtitleIndex or stepIndex for model: \(name)")
            completion(nil)
            return
        }

        let fileName = videos[stepIndex]
        let path = "procedure_videos/"
                 + name.lowercased()
                 + "/"
                 + subtitles[subtitleIndex].lowercased()
                 + "/"
                 + fileName

        print("🟡 Attempting to fetch Firebase path:", path)

        Storage.storage()
            .reference()
            .child(path)
            .downloadURL { url, error in
                if let error = error {
                    print("🔴 Firebase download error:", error.localizedDescription)
                    completion(nil)
                } else {
                    print("✅ Got video URL:", url?.absoluteString ?? "")
                    completion(url)
                }
            }
    }
}
