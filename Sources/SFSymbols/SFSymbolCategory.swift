public struct SFSymbolCategory: Identifiable, Hashable, Sendable {
    public let id: String
    public let key: String
    public let icon: SFSymbol
    public let symbols: [SFSymbol]

    init(key: String, icon: SFSymbol, symbols: [SFSymbol]) {
        self.id = key
        self.key = key
        self.icon = icon
        self.symbols = symbols
    }
}

public extension Array where Element == SFSymbolCategory {
    private enum Key {
        static let whatsNew = "whatsnew"
        static let variable = "variable"
        static let multicolor = "multicolor"
    }

    var displayable: [Element] {
        var result: [Element] = []
        var trailing: [Element] = []
        for element in self {
            guard element.key != Key.whatsNew else {
                continue
            }
            if element.key == Key.variable || element.key == Key.multicolor {
                trailing.append(element)
            } else {
                result.append(element)
            }
        }
        result += trailing
        return result
    }
}
