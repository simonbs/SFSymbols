import SwiftUI

enum SymbolRenderingModeSetting: String, CaseIterable, Identifiable {
    case monochrome
    case hierarchical
    case palette
    case multicolor

    var id: Self {
        self
    }

    var title: LocalizedStringResource {
        switch self {
        case .monochrome:
            "Monochrome"
        case .hierarchical:
            "Hierarchical"
        case .palette:
            "Palette"
        case .multicolor:
            "Multicolor"
        }
    }
}

extension SymbolRenderingMode {
    init(_ mode: SymbolRenderingModeSetting) {
        switch mode {
        case .monochrome:
            self = .monochrome
        case .hierarchical:
            self = .hierarchical
        case .palette:
            self = .palette
        case .multicolor:
            self = .multicolor
        }
    }
}
