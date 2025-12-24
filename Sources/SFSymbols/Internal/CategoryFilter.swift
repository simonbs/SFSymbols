import SwiftUI

enum CategoryFilter: Identifiable, Hashable, Sendable {
    case all
    case category(SFSymbolCategory)

    var id: String {
        switch self {
        case .all:
            "all"
        case .category(let category):
            "category:\(category.key)"
        }
    }

    var image: Image {
        switch self {
        case .all:
            Image(systemName: "square.grid.2x2")
        case .category(let category):
            Image(systemName: category.icon.name)
        }
    }
}
