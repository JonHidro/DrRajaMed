//
//  Navigation.swift
//  DrRaja Prototype #3
//
//  Created by Jonathan Hidrogo on 4/9/25.
//

import SwiftUI

class NavigationManager: ObservableObject {
    /// Only detail destinations now — tabs are controlled by UI state in MainContainerView
    enum Destination: Hashable {
        case procedureDetail(ProcedureModel)
        case caseDetail(CaseModel)
    }
    
    /// Backed by SwiftUI’s NavigationPath
    @Published var navigationPath = NavigationPath()
    
    /// Push a new detail view
    func push(_ destination: Destination) {
        navigationPath.append(destination)
    }
    
    /// Pop one level
    func goBack() {
        navigationPath.removeLast()
    }
    
    /// Clear all detail pushes
    func goToRoot() {
        navigationPath = NavigationPath()
    }
}
