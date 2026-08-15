import Foundation

public extension SFSymbols {
    func search(
        matching searchText: String,
        categoryFilter: SFSymbolCategoryFilter = .all
    ) -> [SFSymbol] {
        symbols.search(matching: searchText, categoryFilter: categoryFilter)
    }

    func search(
        matching searchText: String,
        categoryFilter: SFSymbolCategoryFilter = .all,
        limit: Int
    ) -> [SFSymbol] {
        symbols.search(matching: searchText, categoryFilter: categoryFilter, limit: limit)
    }
}

public extension Array where Element == SFSymbol {
    func search(
        matching searchText: String,
        categoryFilter: SFSymbolCategoryFilter = .all
    ) -> [SFSymbol] {
        search(matching: searchText, categoryFilter: categoryFilter, limit: .unlimited)
    }

    func search(
        matching searchText: String,
        categoryFilter: SFSymbolCategoryFilter = .all,
        limit: Int
    ) -> [SFSymbol] {
        search(matching: searchText, categoryFilter: categoryFilter, limit: .limited(limit))
    }
}

private extension Array where Element == SFSymbol {
    func search(
        matching searchText: String,
        categoryFilter: SFSymbolCategoryFilter,
        limit: SFSymbols.SearchLimit
    ) -> [SFSymbol] {
        let categoryFilteredSymbols = switch categoryFilter {
        case .all:
            self
        case .category(let category):
            filter { $0.categories.contains(category.key) }
        }
        let normalizedSearchText = searchText.normalizedForSymbolSearch
        guard !normalizedSearchText.isEmpty else {
            return Array(categoryFilteredSymbols.prefix(limit.count(for: categoryFilteredSymbols.count)))
        }
        let sortedResults = categoryFilteredSymbols.enumerated()
            .compactMap { index, symbol in
                SFSymbols.SearchResult(symbol: symbol, originalIndex: index, matching: normalizedSearchText)
            }
            .sorted()
        let limitedResults = sortedResults.prefix(limit.count(for: sortedResults.count))
        return limitedResults.map(\.symbol)
    }
}

extension SFSymbols {
    static func hasSearchableText(_ searchText: String) -> Bool {
        !searchText.normalizedForSymbolSearch.isEmpty
    }

    static func canRefineSearchResults(from oldSearchText: String, to searchText: String) -> Bool {
        let oldNormalizedSearchText = oldSearchText.normalizedForSymbolSearch
        let normalizedSearchText = searchText.normalizedForSymbolSearch
        return !oldNormalizedSearchText.isEmpty && normalizedSearchText.hasPrefix(oldNormalizedSearchText)
    }
}

private extension SFSymbols {
    enum SearchLimit {
        case unlimited
        case limited(Int)

        func count(for resultCount: Int) -> Int {
            switch self {
            case .unlimited:
                resultCount
            case .limited(let limit):
                limit
            }
        }
    }

    struct SearchResult: Comparable {
        let symbol: SFSymbol
        let rank: Int
        let originalIndex: Int

        init?(symbol: SFSymbol, originalIndex: Int, matching searchText: String) {
            let normalizedName = symbol.name.normalizedForSymbolSearch
            guard let rank = Self.rank(for: symbol, normalizedName: normalizedName, matching: searchText) else {
                return nil
            }
            self.symbol = symbol
            self.rank = rank
            self.originalIndex = originalIndex
        }

        static func < (lhs: Self, rhs: Self) -> Bool {
            if lhs.rank != rhs.rank {
                return lhs.rank < rhs.rank
            } else if lhs.prefersNameOrdering {
                if lhs.symbol.name.count != rhs.symbol.name.count {
                    return lhs.symbol.name.count < rhs.symbol.name.count
                } else {
                    return lhs.symbol.name.localizedStandardCompare(rhs.symbol.name) == .orderedAscending
                }
            } else {
                return lhs.originalIndex < rhs.originalIndex
            }
        }
    }

    enum SearchNormalization {
        static let ignoredCharacters = allowedCharacters.inverted

        private static let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz0123456789")
    }
}

private extension SFSymbols.SearchResult {
    var prefersNameOrdering: Bool {
        rank <= 3 || rank == 6 || rank == 7
    }

    static func rank(for symbol: SFSymbol, normalizedName: String, matching searchText: String) -> Int? {
        if normalizedName == searchText {
            return 0
        } else if let variantDepth = symbol.name.variantDepth(relativeTo: searchText) {
            return variantDepth == 1 ? 1 : 2
        } else if normalizedName.hasPrefix(searchText) {
            return 3
        } else if symbol.searchTerms.contains(where: { searchTerm in
            searchTerm.normalizedForSymbolSearch == searchText
        }) {
            return 4
        } else if symbol.searchTerms.contains(where: { searchTerm in
            searchTerm.normalizedForSymbolSearch.hasPrefix(searchText)
        }) {
            return 5
        } else if symbol.name.trailingNormalizedComponents.contains(searchText) {
            return 6
        } else if normalizedName.contains(searchText) {
            return 7
        } else if symbol.searchTerms.contains(where: { searchTerm in
            searchTerm.normalizedForSymbolSearch.contains(searchText)
        }) {
            return 8
        } else {
            return nil
        }
    }
}

private extension String {
    var normalizedForSymbolSearch: String {
        lowercased()
            .components(separatedBy: SFSymbols.SearchNormalization.ignoredCharacters)
            .joined()
    }

    var trailingNormalizedComponents: [String] {
        split(separator: ".").dropFirst().map { String($0).normalizedForSymbolSearch }
    }

    func variantDepth(relativeTo searchText: String) -> Int? {
        let normalizedComponents = split(separator: ".").map { String($0).normalizedForSymbolSearch }
        guard normalizedComponents.first == searchText, normalizedComponents.count > 1 else {
            return nil
        }
        return normalizedComponents.count - 1
    }
}
