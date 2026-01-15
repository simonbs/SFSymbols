import Foundation

struct SymbolCategoriesPlist: Decodable {
    let symbols: [String: [String]]

    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        symbols = try container.decode([String: [String]].self)
    }
}

extension SymbolCategoriesPlist: CustomDebugStringConvertible {
    var debugDescription: String {
        let symbolsPrefix = symbols.keys.prefix(10).joined(separator: ", ")
        return "[SymbolCategoriesPlist \(symbols.count) symbols: \(symbolsPrefix), ...]"
    }
}
