//
//  CaseModel.swift
//  DrRaja Prototype #3
//
//  Created by Jonathan Hidrogo on 3/25/25.
//

import SwiftUI
import Foundation

struct CaseModel: Identifiable, Hashable, Codable {
    let id: UUID
    let title: String
    let description: String
    let imageName: String

    /// These show up as colored badges on your card
    let cardTags: [String]

    /// These drive your subtitle picker & video lookup
    let subtitles: [String]
    let videoFilesBySubtitle: [String: [String]]

    /// Designated initializer — you can pass in your own `id` for testing or decoding
    init(
        id: UUID = .init(),
        title: String,
        description: String,
        imageName: String,
        cardTags: [String]            = [],
        subtitles: [String]           = [],
        videoFilesBySubtitle: [String: [String]] = [:]
    ) {
        self.id                    = id
        self.title                 = title
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

extension CaseModel {
    static let sample1 = CaseModel(
        title: "Case 1: STEMI",
        description: "A 54‑year‑old male presents with chest pain…",
        imageName: "stemi_image",
        cardTags: ["LAD", "Acute"],             // colored badges on the card
        subtitles: ["LAD", "Acute"],            // order for the picker
        videoFilesBySubtitle: [
            "LAD":    ["stemi_video1", "stemi_video2"],
            "Acute": ["stemi_video3"]
        ]
    )

    static let sample2 = CaseModel(
        title: "Case 2: NSTEMI",
        description: "A 67‑year‑old female with hypertension…",
        imageName: "nstemi_image",
        cardTags: ["RCA", "Subacute"],
        subtitles: ["RCA", "Subacute"],
        videoFilesBySubtitle: [
            "RCA":     ["nstemi_video1"],
            "Subacute":["nstemi_video2"]
        ]
    )
}
