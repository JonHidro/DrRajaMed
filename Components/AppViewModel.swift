//
//  AppViewModel.swift
//  DrRajaMed
//
//  Created by Jonathan Hidrogo on 4/16/25.
//

import SwiftUI

class AppViewModel: ObservableObject {
    @Published var procedures: [ProcedureModel]
    @Published var cases: [CaseModel]

    init() {
        self.procedures = [
            ProcedureModel(
                id: UUID(),
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
        ]

        self.cases = [
            CaseModel(
                id: UUID(),
                title: "Case 1: STEMI",
                description: "A 54‑year‑old male presents with chest pain…",
                imageName: "stemi_image",
                cardTags: ["LAD", "Acute"],
                subtitles: ["LAD", "Acute"],
                videoFilesBySubtitle: [
                    "LAD":    ["stemi_video1", "stemi_video2"],
                    "Acute": ["stemi_video3"]
                ]
            ),
            CaseModel(
                id: UUID(),
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
        ]
    }
}
