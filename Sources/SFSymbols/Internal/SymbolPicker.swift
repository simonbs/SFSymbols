import SwiftUI

struct SymbolPicker: View {
    @Binding var selection: String?
    let symbols: SFSymbols

    @State private var searchText = ""
    @State private var categoryFilter: CategoryFilter = .all
    @FocusState private var isSearchBarFocused: Bool
    @State private var currentSymbols: [SFSymbol] = []
    @State private var searchTask: Task<Void, Never>?
    private var showSearchResults: Bool {
        !searchText.normalizedForSearch.isEmpty
    }

    var body: some View {
        ZStack {
            if showSearchResults && currentSymbols.isEmpty {
                ContentUnavailableView(
                    "No Symbols",
                    systemImage: "magnifyingglass",
                    description: Text("No results found for ”\(searchText)”")
                )
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        Color.clear
                            .frame(height: 0)
                            .id("top")
                        SymbolGrid(symbols: currentSymbols, selection: $selection)
                    }
                    .onChange(of: currentSymbols) { _, _ in
                        proxy.scrollTo("top", anchor: .top)
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            if !isSearchBarFocused && !showSearchResults {
                CategoryFilterPicker(categories: symbols.displayableCategories, selection: $categoryFilter)
                    .transition(.opacity.animation(.linear(duration: 0.1)))
                #if os(macOS)
                    .padding(.bottom)
                    .frame(maxWidth: 500)
                #endif
            }
        }
        .searchable(text: $searchText)
        .modifier(SearchBarFocusedViewModifier(binding: $isSearchBarFocused))
        .onAppear {
            updateCurrentResults()
        }
        .onChange(of: searchText) { oldValue, _ in
            updateCurrentResults(oldSearchText: oldValue)
        }
        .onChange(of: categoryFilter) { _, _ in
            updateCurrentResults()
        }
    }
}

private extension SymbolPicker {
    private func updateCurrentResults(oldSearchText: String = "") {
        searchTask?.cancel()
        let oldNormalizedSearchText = oldSearchText.normalizedForSearch
        let normalizedSearchText = searchText.normalizedForSearch
        let symbols = if !oldSearchText.isEmpty, normalizedSearchText.hasPrefix(oldNormalizedSearchText) {
            currentSymbols
        } else {
            symbols.symbols
        }
        searchTask = Task.detached(priority: .userInitiated) { [normalizedSearchText, categoryFilter, symbols] in
            guard !Task.isCancelled else {
                return
            }
            let resultSymbols = symbols.filtered(using: categoryFilter, searchText: normalizedSearchText)
            guard !Task.isCancelled else {
                return
            }
            await MainActor.run {
                guard self.searchText.normalizedForSearch == normalizedSearchText else {
                    return
                }
                guard self.categoryFilter == categoryFilter else {
                    return
                }
                self.currentSymbols = resultSymbols
            }
        }
    }
}

private extension SFSymbols {
    var displayableCategories: [SFSymbolCategory] {
        categories.filter { category in
            category.key != "whatsnew"
            && category.key != "variable"
            && category.key != "multicolor"
        }
    }
}

private extension Array where Element == SFSymbol {
    func filtered(using categoryFilter: CategoryFilter, searchText: String) -> [Element] {
        let showSearchResults = !searchText.isEmpty
        switch (showSearchResults, categoryFilter) {
        case (false, .category(let category)):
            return filter { $0.categories.contains(category.key) }
        case (false, .all):
            return self
        case (true, _):
            return filter { symbol in
                let terms = [symbol.name] + symbol.searchTerms
                return terms.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
    }
}

private extension String {
    var normalizedForSearch: String {
        trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}

private struct SearchBarFocusedViewModifier: ViewModifier {
    @FocusState<Bool>.Binding var binding: Bool

    func body(content: Content) -> some View {
        if #available(iOS 18, macOS 15, *) {
            content.searchFocused($binding)
        } else {
            content
        }
    }
}
