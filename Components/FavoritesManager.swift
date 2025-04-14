//
//  Untitled.swift
//  DrRaja Prototype #3
//
//  Created by Jonathan Hidrogo on 4/8/25.
//

import SwiftUI

/// Holds the user’s favorited items
final class FavoritesManager: ObservableObject {
    @Published var procedures: [ProcedureModel] = []
    @Published var cases:      [CaseModel]      = []
}
