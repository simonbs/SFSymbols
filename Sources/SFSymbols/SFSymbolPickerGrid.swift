import SwiftUI

public struct SFSymbolPickerGrid: View {
    public struct Configuration {
        public let edgePadding: CGFloat
        public let preferredItemSize: CGSize
        public let itemSpacing: CGFloat

        #if os(iOS)
        public init(
            edgePadding: CGFloat = 0,
            preferredItemSize: CGSize = CGSize(width: 57, height: 45),
            itemSpacing: CGFloat = 14
        ) {
            self.edgePadding = edgePadding
            self.preferredItemSize = preferredItemSize
            self.itemSpacing = itemSpacing
        }
        #elseif os(macOS)
        public init(
            edgePadding: CGFloat = 0,
            preferredItemSize: CGSize = CGSize(width: 51, height: 41),
            itemSpacing: CGFloat = 10
        ) {
            self.edgePadding = edgePadding
            self.preferredItemSize = preferredItemSize
            self.itemSpacing = itemSpacing
        }
        #endif
    }

    @Binding private var selection: String?
    private let symbols: [SFSymbol]
    private let categoryFilter: SFSymbolCategoryFilter
    private let searchText: String
    private let configuration: Configuration

    @State private var currentSymbols: [SFSymbol] = []
    @State private var searchTask: Task<Void, Never>?
    private var showSearchResults: Bool {
        !searchText.normalizedForSearch.isEmpty
    }

    public init(
        selection: Binding<String?>,
        symbols: [SFSymbol],
        categoryFilter: SFSymbolCategoryFilter = .all,
        searchText: String = "",
        configuration: Configuration = Configuration()
    ) {
        self._selection = selection
        self.symbols = symbols
        self.categoryFilter = categoryFilter
        self.searchText = searchText
        self.configuration = configuration
    }

    public init(
        selection: Binding<String>,
        symbols: [SFSymbol],
        categoryFilter: SFSymbolCategoryFilter = .all,
        searchText: String = "",
        configuration: Configuration = Configuration()
    ) {
        self._selection = Binding {
            selection.wrappedValue
        } set: { newValue in
            selection.wrappedValue = newValue ?? selection.wrappedValue
        }
        self.symbols = symbols
        self.categoryFilter = categoryFilter
        self.searchText = searchText
        self.configuration = configuration
    }

    public var body: some View {
        ZStack {
            if showSearchResults && currentSymbols.isEmpty {
                ContentUnavailableView(
                    "No Symbols",
                    systemImage: "magnifyingglass",
                    description: Text("No results found for ”\(searchText)”")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        SFSymbolsGrid(
                            symbols: currentSymbols,
                            selection: $selection,
                            edgePadding: configuration.edgePadding,
                            preferredItemSize: configuration.preferredItemSize,
                            itemSpacing: configuration.itemSpacing
                        )
                        .background(alignment: .top) {
                            Color.clear
                                .frame(height: 10)
                                .id("top")
                        }
                    }
                    .onChange(of: currentSymbols) { _, _ in
                        proxy.scrollTo("top", anchor: .top)
                    }
                }
            }
        }
        .onAppear {
            updateCurrentResults()
        }
        .onDisappear {
            searchTask?.cancel()
        }
        .onChange(of: searchText) { oldValue, _ in
            updateCurrentResults(oldSearchText: oldValue)
        }
        .onChange(of: categoryFilter) { _, _ in
            updateCurrentResults()
        }
        .onChange(of: symbols) { _, _ in
            updateCurrentResults()
        }
        .sensoryFeedback(.selection, trigger: selection)
    }
}

private extension SFSymbolPickerGrid {
    private func updateCurrentResults(oldSearchText: String = "") {
        searchTask?.cancel()
        let oldNormalizedSearchText = oldSearchText.normalizedForSearch
        let normalizedSearchText = searchText.normalizedForSearch
        let symbolsToFilter = if !oldSearchText.isEmpty, normalizedSearchText.hasPrefix(oldNormalizedSearchText) {
            currentSymbols
        } else {
            symbols
        }
        searchTask = Task.detached(
            name: "SFSymbolPicker Filter",
            priority: .userInitiated
        ) { [normalizedSearchText, categoryFilter, symbolsToFilter] in
            guard !Task.isCancelled else {
                return
            }
            let resultSymbols = symbolsToFilter.filtered(using: categoryFilter, searchText: normalizedSearchText)
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

private extension Array where Element == SFSymbol {
    func filtered(using categoryFilter: SFSymbolCategoryFilter, searchText: String) -> [Element] {
        let categoryFilteredSymbols: [Element]
        switch categoryFilter {
        case .all:
            categoryFilteredSymbols = self
        case .category(let category):
            categoryFilteredSymbols = filter { $0.categories.contains(category.key) }
        }
        guard !searchText.isEmpty else {
            return categoryFilteredSymbols
        }
        return categoryFilteredSymbols.filter { symbol in
            let terms = [symbol.name] + symbol.searchTerms
            return terms.contains { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
}
