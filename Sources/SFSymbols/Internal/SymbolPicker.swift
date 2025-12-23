import SwiftUI

struct SymbolPicker: View {
    @Binding var selection: String?
    let symbols: SFSymbols

    @State private var searchText = ""
    @State private var filter: CategoryFilter = .noFilter
    @FocusState private var isSearchBarFocused: Bool
    private var safeSearchText: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    private var showSearchResults: Bool {
        !safeSearchText.isEmpty
    }
    private var enabledCategories: [SFSymbolCategory] {
        symbols.categories.filter { category in
            category.key != "whatsnew"
            && category.key != "variable"
            && category.key != "multicolor"
        }
    }
    private var currentSymbols: [SFSymbol] {
        switch (showSearchResults, filter) {
        case (true, _):
            let safeSearchText = self.safeSearchText
            return symbols.symbols.filter { symbol in
                let terms = [symbol.name] + symbol.searchTerms
                return terms.contains { $0.localizedCaseInsensitiveContains(safeSearchText) }
            }
        case (false, .filter(let category)):
            return symbols.symbols.filter { $0.categories.contains(category.key) }
        case (false, .noFilter):
            return symbols.symbols
        }
    }
    private var currentSymbolsKey: String {
        switch (showSearchResults, filter) {
        case (true, _):
            return "search:\(safeSearchText.lowercased())"
        case (false, .filter(let category)):
            return "category:\(category.key)"
        case (false, .noFilter):
            return "all"
        }
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
                    .onChange(of: currentSymbolsKey) { _, _ in
                        proxy.scrollTo("top", anchor: .top)
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            if !isSearchBarFocused && !showSearchResults {
                CategoryFilterPicker(categories: enabledCategories, selection: $filter)
                    .transition(.opacity.animation(.linear(duration: 0.1)))
                #if os(macOS)
                    .padding(.bottom)
                    .frame(maxWidth: 500)
                #endif
            }
        }
        .searchable(text: $searchText)
        .modifier(SearchBarFocusedViewModifier(binding: $isSearchBarFocused))
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
