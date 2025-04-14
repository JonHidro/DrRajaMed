//
//  ProcedureInstances.swift
//  DrRaja Prototype #3
//
//  Created by Jonathan Hidrogo on 3/25/25.
//

import SwiftUI
import Foundation

let procedures: [ProcedureModel] = [
  // 1) Angioplasty
  ProcedureModel(
    name:        "Angioplasty",
    description: "A minimally invasive artery procedure.",
    imageName:   "angioplasty_image",           // your “angioplasty” asset
    cardTags:    ["SFA"],
    subtitles:   ["SFA"],
    videoFilesBySubtitle: [
      "SFA": ["angioplasty_step1","angioplasty_step2"]
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
