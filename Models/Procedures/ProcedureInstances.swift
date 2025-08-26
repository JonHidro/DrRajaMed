//
//  ProcedureInstances.swift
//  DrRaja Prototype #3
//
//  Created by Jonathan Hidrogo on 3/25/25.
//

import SwiftUI
import Foundation

let procedures: [ProcedureModel] = [
    ProcedureModel(
        name:        "Angioplasty",
        description: "A minimally invasive artery procedure.",
        imageName:   "angioplasty_image",
        cardTags:    ["SFA", "ILIAC"],
        subtitles:   ["SFA", "ILIAC"],
        videoFilesBySubtitle: [
            "SFA": [
                "RajaAppIntro1.mp4",
                "RajaAppCase1DEMO.mp4",
                "angioplasty_step3.mp4", // ✅ typo fixed from 'setp3' to 'step3' Dont foregt to input .mp4 after
                "angioplasty_step4"
            ],
            "Illiac": [
                "iliac_step1",
                "iliac_step2",
                "iliac_step3",
                "iliac_step4"
            ]
        ]
  ),

  // 2) CTO
  ProcedureModel(
    name:        "CTO",
    description: "Chronic Total Occlusion procedure.",
    imageName:   "ffr_image",                   // your “cto” asset
    cardTags:    ["ILIAC"],
    subtitles:   ["ILIAC"],
    videoFilesBySubtitle: [
      "ILIAC": ["cto_step1"]
    ]
  ),

  // 3) DVA
  ProcedureModel(
    name:        "DVA",
    description: "Directional vessel atherectomy to remove plaque.",
    imageName:   "dva_image",                   // your “dva” asset
    cardTags:    ["Femoral"],
    subtitles:   ["Femoral"],
    videoFilesBySubtitle: [
      "Femoral": ["dva_step1"]
    ]
  )
]
