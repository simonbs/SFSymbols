import Foundation
import OSLog

public struct SFSymbols: Sendable {
    public let symbols: [SFSymbol]
    public let categories: [SFSymbolCategory]

    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "SFSymbols")

    public init() async throws {
        do {
            let reader = CoreGlyphsPlistReader()
            async let _categoriesPlist = try reader.read(plistNamed: "categories", as: CategoriesPlist.self)
            async let _symbolOrderPlist = try reader.read(plistNamed: "symbol_order", as: SymbolOrderPlist.self)
            let (categoriesPlist, symbolOrderPlist) = try await (_categoriesPlist, _symbolOrderPlist)
            let (symbols, symbolNameMap) = try await Self.symbols(using: reader, categoriesPlist: categoriesPlist)
            let sortedSymbols = Self.sortSymbols(symbols, accordingTo: symbolOrderPlist.names)
            self.symbols = sortedSymbols
            self.categories = Self.categories(
                categoriesPlist: categoriesPlist,
                symbols: sortedSymbols,
                symbolNameMap: symbolNameMap
            )
        } catch {
            Self.logger.error("Could not load SF Symbols: \(error, privacy: .public)")
            throw error
        }
    }
}

private extension SFSymbols {
    private static func symbols(
        using reader: CoreGlyphsPlistReader,
        categoriesPlist: CategoriesPlist
    ) async throws -> ([SFSymbol], [String: SFSymbol]) {
        async let _nameAvailabilityPlist = try reader.read(plistNamed: "name_availability", as: NameAvailabilityPlist.self)
        async let _symbolSearchPlist = try reader.read(plistNamed: "symbol_search", as: SymbolSearchPlist.self)
        async let _symbolCategoriesPlist = try reader.read(plistNamed: "symbol_categories", as: SymbolCategoriesPlist.self)
        let (nameAvailabilityPlist, symbolSearchPlist, symbolCategoriesPlist) = try await (
            _nameAvailabilityPlist,
            _symbolSearchPlist,
            _symbolCategoriesPlist
        )
        var symbols: [SFSymbol] = []
        symbols.reserveCapacity(nameAvailabilityPlist.availableSymbols.count)
        var symbolNameMap: [String: SFSymbol] = [:]
        symbolNameMap.reserveCapacity(nameAvailabilityPlist.availableSymbols.count)
        for symbol in nameAvailabilityPlist.availableSymbols {
            let searchTerms = symbolSearchPlist.symbols[symbol.name] ?? []
            let categories = symbolCategoriesPlist.symbols[symbol.name] ?? []
            let symbol = SFSymbol(
                name: symbol.name,
                searchTerms: searchTerms,
                categories: categories
            )
            symbolNameMap[symbol.name] = symbol
            symbols.append(symbol)
        }
        return (symbols, symbolNameMap)
    }

    private static func categories(
        categoriesPlist: CategoriesPlist,
        symbols: [SFSymbol],
        symbolNameMap: [String: SFSymbol]
    ) -> [SFSymbolCategory] {
        var categoryKeyMap: [String: [SFSymbol]] = [:]
        categoryKeyMap.reserveCapacity(categoriesPlist.categories.count)
        for category in categoriesPlist.categories {
            categoryKeyMap[category.key] = []
        }
        for symbol in symbols {
            for category in symbol.categories {
                categoryKeyMap[category, default: []].append(symbol)
            }
        }
        return categoriesPlist.categories.compactMap { category in
            guard let icon = symbolNameMap[category.icon] else {
                return nil
            }
            guard let symbolsInCategory = categoryKeyMap[category.key] else {
                return nil
            }
            guard !symbolsInCategory.isEmpty else {
                return nil
            }
            return SFSymbolCategory(key: category.key, icon: icon, symbols: symbolsInCategory)
        }
    }

    private static func sortSymbols(_ symbols: [SFSymbol], accordingTo sortedNames: [String]) -> [SFSymbol] {
        var symbolMap: [String: SFSymbol] = [:]
        symbolMap.reserveCapacity(symbols.count)
        for symbol in symbols {
            symbolMap[symbol.name] = symbol
        }
        var orderedSymbols: [SFSymbol] = []
        orderedSymbols.reserveCapacity(symbols.count)
        for name in sortedNames {
            if let symbol = symbolMap[name] {
                orderedSymbols.append(symbol)
            }
        }
        let sortedNameSet = Set(sortedNames)
        for symbol in symbols where !sortedNameSet.contains(symbol.name) {
            orderedSymbols.append(symbol)
        }
        return orderedSymbols
    }
}
