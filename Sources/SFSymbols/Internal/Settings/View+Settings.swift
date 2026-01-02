import SwiftUI

extension View {
    @ViewBuilder
    func symbolColorRenderingModeSetting(_ setting: SymbolColorRenderingModeSetting) -> some View {
        if #available(iOS 26, macOS 26, *) {
            switch setting {
            case .flat:
                symbolColorRenderingMode(.flat)
            case .gradient:
                symbolColorRenderingMode(.gradient)
            }
        } else {
            self
        }
    }

    @ViewBuilder
    func symbolColorsSetting(_ setting: SymbolColorsSetting) -> some View {
        if let secondaryColor = setting.secondaryColor, let tertiaryColor = setting.tertiaryColor {
            foregroundStyle(setting.primaryColor, secondaryColor, tertiaryColor)
        } else if let secondaryColor = setting.secondaryColor {
            foregroundStyle(setting.primaryColor, secondaryColor)
        } else {
            foregroundStyle(setting.primaryColor)
        }
    }

    @ViewBuilder
    func symbolVariableValueModeSetting(_ setting: SymbolVariableValueModeSetting) -> some View {
        if #available(iOS 26, macOS 26, *) {
            switch setting {
            case .color:
                symbolVariableValueMode(SymbolVariableValueMode.color)
            case .draw:
                symbolVariableValueMode(SymbolVariableValueMode.draw)
            }
        } else {
            self
        }
    }
}
