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
