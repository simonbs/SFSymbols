import Foundation

struct SymbolOrderPlist: Decodable {
    let names: [String]

    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        names = try container.decode([String].self)
    }
}

extension SymbolOrderPlist: CustomDebugStringConvertible {
    var debugDescription: String {
        let symbolsPrefix = names.prefix(10).joined(separator: ", ")
        return "[SymbolOrderPlist \(names.count) symbols: \(symbolsPrefix), ...]"
    }
}
