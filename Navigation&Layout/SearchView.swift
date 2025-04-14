//
//  SearchView.swift
//  DrRaja Prototype #3
//
//  Created by Jonathan Hidrogo on 3/23/25.
//

import SwiftUI

struct SearchView: View {
    let cases: [CaseModel]
    let procedures: [ProcedureModel]
    
    @State private var searchText: String = ""
    @State private var recentSearches: [String] = UserDefaults.standard.stringArray(forKey: "RecentSearches") ?? []
    
    // Build a unified list of all cases & procedures
    private var allItems: [SearchResult] {
        cases.map {
            SearchResult(
                title: $0.title,
                imageName: $0.imageName,
                description: $0.description
            )
        } + procedures.map {
            SearchResult(
                title: $0.name,
                imageName: $0.imageName,
                description: $0.description
            )
        }
    }
    
    // Filtered by the search text
    private var filteredResults: [SearchResult] {
        guard !searchText.isEmpty else { return [] }
        return allItems.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // MARK: – Search Bar
                HStack {
                    TextField("Search cases & procedures...", text: $searchText, onCommit: saveSearch)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing, 10)
                    }
                }
                
                // MARK: – Recent Searches
                if !recentSearches.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Recent Searches")
                                .font(.headline)
                                .padding(.leading)
                            Spacer()
                            Button("Clear All", action: clearRecentSearches)
                                .font(.subheadline)
                                .foregroundColor(.red)
                                .padding(.trailing)
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(recentSearches, id: \.self) { search in
                                    Button(search) {
                                        searchText = search
                                    }
                                    .padding(8)
                                    .background(Color(.secondarySystemBackground))
                                    .cornerRadius(8)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // MARK: – Results
                List(filteredResults) { result in
                    NavigationLink(destination: destination(for: result)) {
                        HStack(spacing: 12) {
                            Image(result.imageName)
                                .resizable()
                                .frame(width: 50, height: 50)
                                .cornerRadius(8)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(result.title)
                                    .font(.headline)
                                Text(result.description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Search")
        }
    }
    
    // MARK: – Helpers
    private func destination(for result: SearchResult) -> some View {
        if let match = procedures.first(where: { $0.name == result.title }) {
            return AnyView(ProcedureDetailView(procedure: match))
        } else if let match = cases.first(where: { $0.title == result.title }) {
            return AnyView(CaseDetailView(caseItem: match))
        } else {
            return AnyView(
                VStack {
                    Text("No detail view found for \(result.title).")
                        .font(.title3)
                        .padding()
                    Spacer()
                }
            )
        }
    }
    
    private func saveSearch() {
        let allValidTitles = cases.map { $0.title } + procedures.map { $0.name }
        guard allValidTitles.contains(searchText),
              !recentSearches.contains(searchText)
        else { return }
        
        recentSearches.insert(searchText, at: 0)
        if recentSearches.count > 5 {
            recentSearches.removeLast()
        }
        UserDefaults.standard.set(recentSearches, forKey: "RecentSearches")
    }
    
    private func clearRecentSearches() {
        recentSearches.removeAll()
        UserDefaults.standard.removeObject(forKey: "RecentSearches")
    }
}

// MARK: – SearchResult

struct SearchResult: Identifiable {
    let id = UUID()
    let title: String
    let imageName: String
    let description: String
}

// MARK: – Preview

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        // Provide dummy data as needed.
        SearchView(cases: [], procedures: [])
    }
}
