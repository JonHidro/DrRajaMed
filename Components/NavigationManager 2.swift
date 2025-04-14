//
//  NavigationManager 2.swift
//  DrRaja Prototype #3
//
//  Created by Jonathan Hidrogo on 4/10/25.
//


import SwiftUI

class NavigationManager: ObservableObject {
    enum Destination: Hashable {
        case home, search, favorites, notifications, profile
        case procedureDetail(ProcedureModel)
        case caseDetail(CaseModel)
        
        func hash(into hasher: inout Hasher) {
            switch self {
            case .home:
                hasher.combine(0)
            case .search:
                hasher.combine(1)
            case .favorites:
                hasher.combine(2)
            case .notifications:
                hasher.combine(3)
            case .profile:
                hasher.combine(4)
            case .procedureDetail(let procedure):
                hasher.combine(5)
                hasher.combine(procedure) // ProcedureModel is already Hashable
            case .caseDetail(let caseModel):
                hasher.combine(6)
                hasher.combine(caseModel) // CaseModel is already Hashable
            }
        }
        
        static func == (lhs: Destination, rhs: Destination) -> Bool {
            switch (lhs, rhs) {
            case (.home, .home), (.search, .search), (.favorites, .favorites),
                 (.notifications, .notifications), (.profile, .profile):
                return true
            case let (.procedureDetail(lhsProc), .procedureDetail(rhsProc)):
                return lhsProc == rhsProc // ProcedureModel is already Equatable
            case let (.caseDetail(lhsCase), .caseDetail(rhsCase)):
                return lhsCase == rhsCase // CaseModel is already Equatable
            default:
                return false
            }
        }
    }
    
    @Published var navigationPath = NavigationPath()
    
    func navigateTo(_ destination: Destination) {
        navigationPath.append(destination)
    }
    
    func goBack() {
        navigationPath.removeLast()
    }
    
    func goToRoot() {
        navigationPath = NavigationPath()
    }
}