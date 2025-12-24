import SwiftUI

struct SFSymbolsView: View {
    @Binding var selection: String?
    let symbols: SFSymbols
    let searchText: String

    @State private var categoryFilter: CategoryFilter = .all
    @State private var currentSymbols: [SFSymbol] = []
    @State private var searchTask: Task<Void, Never>?
    private var showSearchResults: Bool {
        !searchText.normalizedForSearch.isEmpty
    }
    #if os(macOS)
    private var scrollContentTopMargin: CGFloat {
        if #available(macOS 26, *) {
            // Add margin to look harmonious with search bar.
            8
        } else {
            0
        }
    }
    #endif

    var body: some View {
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
                        Color.clear
                            .frame(height: 0)
                            .id("top")
                        SFSymbolsGrid(symbols: currentSymbols, selection: $selection)
                    }
                    #if os(macOS)
                    .contentMargins(.top, scrollContentTopMargin, for: .scrollContent)
                    #endif
                    .onChange(of: currentSymbols) { _, _ in
                        proxy.scrollTo("top", anchor: .top)
                    }
                }
            }
        }
        .modifier(CategoryFilterSafeAreaBarViewModifier(isEnabled: !showSearchResults) {
            CategoryFilterPicker(categories: symbols.displayableCategories, selection: $categoryFilter)
                .transition(.opacity.animation(.linear(duration: 0.1)))
        })
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
    }
}

private extension SFSymbolsView {
    private func updateCurrentResults(oldSearchText: String = "") {
        searchTask?.cancel()
        let oldNormalizedSearchText = oldSearchText.normalizedForSearch
        let normalizedSearchText = searchText.normalizedForSearch
        let symbols = if !oldSearchText.isEmpty, normalizedSearchText.hasPrefix(oldNormalizedSearchText) {
            currentSymbols
        } else {
            symbols.symbols
        }
        searchTask = Task.detached(
            name: "SFSymbolPicker Filter",
            priority: .userInitiated
        ) { [normalizedSearchText, categoryFilter, symbols] in
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

private struct CategoryFilterSafeAreaBarViewModifier<BarContent: View>: ViewModifier {
    let isEnabled: Bool
    @ViewBuilder let barContent: () -> BarContent

    func body(content: Content) -> some View {
        if #available(iOS 26, macOS 26, watchOS 26, visionOS 26, *) {
            content.safeAreaBar(edge: .bottom) {
                if isEnabled {
                    barContent()
                    #if os(iOS)
                        .padding(.horizontal, 28)
                    #elseif os(macOS)
                        .padding([.horizontal, .bottom])
                    #endif
                        .transition(.opacity.animation(.linear(duration: 0.15)))
                }
            }
        } else {
            content.safeAreaInset(edge: .bottom) {
                if isEnabled {
                    VStack(spacing: 0) {
                        Divider()
                        barContent()
                            .padding()
                    }
                    .background(.ultraThinMaterial)
                    .transition(.opacity.animation(.linear(duration: 0.15)))
                }
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
