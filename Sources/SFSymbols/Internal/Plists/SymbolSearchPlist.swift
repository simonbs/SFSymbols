import Foundation

struct SymbolSearchPlist: Decodable {
    let symbols: [String: [String]]

    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        symbols = try container.decode([String: [String]].self)
    }
}

extension SymbolSearchPlist: CustomDebugStringConvertible {
    var debugDescription: String {
        let symbolsPrefix = symbols.keys.prefix(10).joined(separator: ", ")
        return "[SymbolSearchPlist \(symbols.count) symbols: \(symbolsPrefix), ...]"
    }
}
