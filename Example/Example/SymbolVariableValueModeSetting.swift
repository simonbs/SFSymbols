import SFSymbols
import SwiftUI

enum SymbolVariableValueModeSetting: String, CaseIterable, Identifiable {
    case color
    case draw

    var id: Self {
        self
    }

    var title: LocalizedStringResource {
        switch self {
        case .color:
            "Color"
        case .draw:
            "Draw"
        }
    }
}

@available(macOS 26.0, *)
extension SymbolVariableValueMode {
    init(_ setting: SymbolVariableValueModeSetting) {
        switch setting {
        case .color:
            self = .color
        case .draw:
            self = .draw
        }
    }
}

extension View {
    @ViewBuilder
    func backportedSFSymbolPickerVariableValueMode(_ setting: SymbolVariableValueModeSetting) -> some View {
        if #available(iOS 26, macOS 26, *) {
            sfSymbolPickerVariableValueMode(SymbolVariableValueMode(setting))
        } else {
            self
        }
    }
}
