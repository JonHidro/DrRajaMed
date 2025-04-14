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
    let name: String             // was `procedureName`
    let description: String
    let imageName: String

    /// Badges shown on your cards
    let cardTags: [String]

    /// Titles for each video section
    let subtitles: [String]

    /// Mapping subtitle → array of video file base names
    let videoFilesBySubtitle: [String: [String]]

    /// Designated initializer (you can pass your own `id` for testing or decoding)
    init(
        id: UUID = .init(),
        name: String,
        description: String,
        imageName: String,
        cardTags: [String]               = [],
        subtitles: [String]              = [],
        videoFilesBySubtitle: [String: [String]] = [:]
    ) {
        self.id                    = id
        self.name                  = name
        self.description           = description
        self.imageName             = imageName
        self.cardTags              = cardTags
        self.subtitles             = subtitles
        self.videoFilesBySubtitle  = videoFilesBySubtitle
    }

    /// Only subtitles that actually have videos, in the declared order
    var availableSubtitles: [String] {
        subtitles.filter { videoFilesBySubtitle[$0] != nil }
    }
}

extension ProcedureModel {
    /// Fetches the download URL for a given subtitle index and step index
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
            completion(nil)
            return
        }

        let fileName = videos[stepIndex] + ".mp4"
        let path = "procedure_videos/\(name.lowercased())/\(subtitles[subtitleIndex].lowercased())/\(fileName)"
        Storage.storage()
            .reference()
            .child(path)
            .downloadURL { url, error in
                if let error = error {
                    print("Failed to fetch video URL:", error)
                    completion(nil)
                } else {
                    completion(url)
                }
            }
    }
}

extension ProcedureModel {
    static let samplePCI = ProcedureModel(
        name: "PCI: Angioplasty",
        description: "Percutaneous coronary intervention with balloon angioplasty...",
        imageName: "pci_image",
        cardTags: ["PTCA", "Coronary"],
        subtitles: ["Access", "Dilation", "Stenting"],
        videoFilesBySubtitle: [
            "Access":   ["access_step1", "access_step2"],
            "Dilation": ["dilation_step1"],
            "Stenting": ["stent_step1", "stent_step2"]
        ]
    )
}
