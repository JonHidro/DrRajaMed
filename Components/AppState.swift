//
//  AppState.swift
//  DrRajaMed
//
//  Created by Jonathan Hidrogo on 4/17/25.
//

import SwiftUI

class AppState: ObservableObject {
    @Published var selectedTab: Tab = .home
}
