//
//  SearchView.swift
//  DrRaja Prototype #3
//
//  Created by Jonathan Hidrogo on 3/23/25.
//

import SwiftUI

// ─── Filter Categories ──────────────────────────────────────────
enum FilterCategory: String, CaseIterable, Identifiable {
    case coronary   = "Coronary"
    case peripheral = "Peripheral"
    case topics     = "Topics"
    var id: String { rawValue }
}

// ─── Sheet Identifier ───────────────────────────────────────────
struct FilterSheetData: Identifiable {
    let category: FilterCategory
    var id: FilterCategory { category }
}

// ─── Unified Search Result ─────────────────────────────────────
struct SearchResult: Identifiable {
    let id = UUID()
    let title: String
    let imageName: String
    let description: String
    let tags: [String]
    let isProcedure: Bool
}

// ─── Main Search View ───────────────────────────────────────────
struct SearchView: View {
    let cases: [CaseModel]
    let procedures: [ProcedureModel]
    @EnvironmentObject var themeManager: ThemeManager

    // MARK: State
    @State private var searchText = ""
    @State private var recentSearches = UserDefaults.standard.stringArray(forKey: "RecentSearches") ?? []

    @State private var activeSheet: FilterSheetData?
    @State private var selectedCoronary = Set<String>()
    @State private var selectedPeripheral = Set<String>()
    @State private var selectedTopics = Set<String>()

    // MARK: Tag Sets
    private let coronaryTags   = Set(["LAD","RCA"])
    private let peripheralTags = Set(["SFA","Illiac","Femoral"])

    // MARK: Combined Items
    private var allItems: [SearchResult] {
        let caseResults = cases.map { c in
            SearchResult(
                title: c.title,
                imageName: c.imageName,
                description: c.description,
                tags: c.cardTags,
                isProcedure: false
            )
        }
        let procResults = procedures.map { p in
            SearchResult(
                title: p.name,
                imageName: p.imageName,
                description: p.description,
                tags: p.cardTags,
                isProcedure: true
            )
        }
        return caseResults + procResults
    }

    // MARK: Filtered + Searched
    private var displayedItems: [SearchResult] {
        var items = allItems
        if !selectedCoronary.isEmpty {
            items = items.filter { !Set($0.tags).isDisjoint(with: selectedCoronary) }
        }
        if !selectedPeripheral.isEmpty {
            items = items.filter { !Set($0.tags).isDisjoint(with: selectedPeripheral) }
        }
        if !selectedTopics.isEmpty {
            items = items.filter { selectedTopics.contains($0.title) }
        }
        if !searchText.isEmpty {
            items = items.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
        return items
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // ─── Main Content ─────────────────────────────────────
            VStack(spacing: 0) {
                headerView
                searchBar

                if displayedItems.isEmpty {
                    Spacer()
                    Text("No results found")
                        .foregroundColor(.secondary)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(displayedItems) { result in
                                NavigationLink(destination: destination(for: result)) {
                                    resultCard(for: result)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        // NO extra bottom padding here
                    }
                }
            }
            .edgesIgnoringSafeArea(.top)
            .navigationBarHidden(true)
            .environment(\.colorScheme, themeManager.isDarkMode ? .dark : .light)

            // ─── Floating Filter Bar ─────────────────────────────
            filterBar
                .padding(.bottom, 70)     // <-- height of your tab bar (adjust as needed)
                .zIndex(1)
        }
        // ─── Filter Sheet ───────────────────────────────────────
        .sheet(item: $activeSheet) { data in
            FilterOptionsSheet(
                category: data.category,
                options: options(for: data.category),
                selected: binding(for: data.category)
            )
            .presentationDetents([.medium, .large])
        }
    }

    // MARK: The filter bar as its own View
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                filterPill(.coronary,   icon: "heart.fill", selected: !selectedCoronary.isEmpty)
                filterPill(.peripheral, icon: "figure.walk",    selected: !selectedPeripheral.isEmpty)
                filterPill(.topics,     icon: "list.bullet",  selected: !selectedTopics.isEmpty)
            }
            .padding(.vertical, 10)
            .padding(.horizontal)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .shadow(radius: 5, y: -5)
        }
    }
}

// ─── Subviews & Helpers ─────────────────────────────────────────
private extension SearchView {
    var headerView: some View {
        ZStack(alignment: .bottomLeading) {
            RadialGradient(
                gradient: Gradient(colors: [Color.cyan, Color.green]),
                center: .topLeading,
                startRadius: 50,
                endRadius: 400
            )
            .frame(height: 100)
            .ignoresSafeArea(edges: .top)

            Text("Search")
                .font(.largeTitle).bold()
                .foregroundColor(.white)
                .padding(.leading, 16)
                .padding(.bottom, 4)
        }
    }

    var searchBar: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                TextField("Search cases & procedures…", text: $searchText, onCommit: saveSearch)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                Button(action: startVoiceInput) {
                    Image(systemName: "mic.fill")
                }
            }
            .padding(10)
            .background(themeManager.isDarkMode
                ? Color(.systemGray5).opacity(0.3)
                : Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }

    func resultCard(for result: SearchResult) -> some View {
        HStack(spacing: 12) {
            Image(result.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .clipped()
                .cornerRadius(8)
            VStack(alignment: .leading, spacing: 4) {
                Text(result.title)
                    .font(.headline)
                    .foregroundColor(themeManager.isDarkMode ? .blue : .accentColor)
                Text(result.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(themeManager.isDarkMode ? Color(.systemGray5) : Color(.systemGray6))
        )
    }

    func filterPill(_ cat: FilterCategory, icon: String, selected: Bool) -> some View {
        Button {
            activeSheet = FilterSheetData(category: cat)
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(cat.rawValue)
            }
            .foregroundColor(selected ? .white : .primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(selected ? Color.accentColor : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.primary.opacity(0.6), lineWidth: 1)
                    )
            )
        }
    }

    func options(for cat: FilterCategory) -> [String] {
        switch cat {
        case .coronary:
            return Array(Set(allItems.flatMap { $0.tags }))
                .filter { coronaryTags.contains($0) }
        case .peripheral:
            return Array(Set(allItems.flatMap { $0.tags }))
                .filter { peripheralTags.contains($0) }
        case .topics:
            return procedures.map { $0.name }
        }
    }

    func binding(for cat: FilterCategory) -> Binding<Set<String>> {
        switch cat {
        case .coronary:   return $selectedCoronary
        case .peripheral: return $selectedPeripheral
        case .topics:     return $selectedTopics
        }
    }

    func destination(for result: SearchResult) -> some View {
        if let p = procedures.first(where: { $0.name == result.title }) {
            return AnyView(ProcedureDetailView(procedure: p))
        } else if let c = cases.first(where: { $0.title == result.title }) {
            return AnyView(CaseDetailView(caseItem: c))
        } else {
            return AnyView(Text("No detail for \(result.title)"))
        }
    }

    func saveSearch() {
        let valid = cases.map { $0.title } + procedures.map { $0.name }
        guard valid.contains(searchText),
              !recentSearches.contains(searchText)
        else { return }

        recentSearches.insert(searchText, at: 0)
        if recentSearches.count > 5 { recentSearches.removeLast() }
        UserDefaults.standard.set(recentSearches, forKey: "RecentSearches")
    }

    func startVoiceInput() {
        // TODO: Radiology voice input here
    }
}

// ─── Filter Options Sheet ───────────────────────────────────────
struct FilterOptionsSheet: View {
    let category: FilterCategory
    let options: [String]
    @Binding var selected: Set<String>
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum:100), spacing:12)], spacing:12) {
                    ForEach(options, id: \.self) { opt in
                        Button {
                            if selected.contains(opt) { selected.remove(opt) }
                            else { selected.insert(opt) }
                        } label: {
                            Text(opt)
                                .padding(.vertical,8)
                                .padding(.horizontal,12)
                                .background(
                                    RoundedRectangle(cornerRadius:10)
                                        .fill(selected.contains(opt)
                                              ? Color.accentColor.opacity(0.2)
                                              : Color.clear)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius:10)
                                        .stroke(selected.contains(opt)
                                                ? Color.accentColor
                                                : Color.gray,
                                                lineWidth:1)
                                )
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Filter by \(category.rawValue)")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
