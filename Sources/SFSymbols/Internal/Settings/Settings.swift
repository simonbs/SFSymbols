import SwiftUI

enum SymbolBackgroundSetting: Identifiable, Hashable, CaseIterable {
    case `default`
    case light
    case dark

    var id: Self {
        self
    }

    var title: LocalizedStringResource {
        switch self {
        case .default:
            "Default"
        case .light:
            "Light"
        case .dark:
            "Dark"
        }
    }
}

enum SymbolColorRenderingModeSetting: Hashable, Sendable {
    case flat
    case gradient
}

struct SymbolColorsSetting: Hashable, Sendable {
    let primaryColor: Color
    let secondaryColor: Color?
    let tertiaryColor: Color?

    init() {
        primaryColor = .primary
        secondaryColor = .blue
        tertiaryColor = .secondary
    }

    init(color: Color) {
        self.primaryColor = color
        self.secondaryColor = nil
        self.tertiaryColor = nil
    }

    init(primaryColor: Color, secondaryColor: Color) {
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.tertiaryColor = nil
    }

    init(primaryColor: Color, secondaryColor: Color, tertiaryColor: Color) {
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.tertiaryColor = tertiaryColor
    }
}

enum SymbolVariableValueModeSetting: Hashable, Sendable {
    case color
    case draw
}
