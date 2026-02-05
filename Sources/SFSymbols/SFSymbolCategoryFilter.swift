import SwiftUI

public enum SFSymbolCategoryFilter: Identifiable, Hashable, Sendable {
    case all
    case category(SFSymbolCategory)

    public var id: String {
        switch self {
        case .all:
            "all"
        case .category(let category):
            "category:\(category.key)"
        }
    }
}

extension SFSymbolCategoryFilter {
    var image: Image {
        switch self {
        case .all:
            Image(systemName: "square.grid.2x2")
        case .category(let category):
            Image(systemName: category.icon.name)
        }
    }
}
