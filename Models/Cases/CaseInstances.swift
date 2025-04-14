//
//  CaseInstances.swift
//  DrRaja Prototype #3
//
//  Created by Jonathan Hidrogo on 3/26/25.
//

import SwiftUI
import Foundation

let cases: [CaseModel] = [
  // 1) STEMI
  CaseModel(
    title:       "Case #1: STEMI",
    description: "A 54‑year‑old male presents with chest pain…",
    imageName:   "IMG_3423",                 // your “stemi” asset
    cardTags:    ["LAD","Acute"],
    subtitles:   ["LAD","Acute"],
    videoFilesBySubtitle: [
      "LAD":    ["stemi_video1","stemi_video2"],
      "Acute": ["stemi_video3"]
    ]
  ),

  // 2) NSTEMI
  CaseModel(
    title:       "Case #2: NSTEMI",
    description: "A 67‑year‑old female with hypertension…",
    imageName:   "IMG_3917",                // your “nstemi” asset
    cardTags:    ["RCA","Subacute"],
    subtitles:   ["RCA","Subacute"],
    videoFilesBySubtitle: [
      "RCA":     ["nstemi_video1"],
      "Subacute":["nstemi_video2"]
    ]
  )
]
