import SFSymbols
import SwiftUI

enum SymbolColorRenderingModeSetting {
    case flat
    case gradient
}

extension View {
    @ViewBuilder
    func backportedSFSymbolPickerColorRenderingMode(_ setting: SymbolColorRenderingModeSetting) -> some View {
        if #available(iOS 26, macOS 26, *) {
            switch setting {
            case .flat:
                sfSymbolPickerColorRenderingMode(.flat)
            case .gradient:
                sfSymbolPickerColorRenderingMode(.gradient)
            }
        } else {
            self
        }
    }
}
