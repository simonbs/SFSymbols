import SwiftUI

public extension View {
    @ViewBuilder
    func sfSymbolPickerRenderingMode(_ renderingMode: SymbolRenderingMode) -> some View {
        environment(\.symbolPickerRenderingMode, renderingMode)
    }

    @available(iOS 26, macOS 26, *)
    @ViewBuilder
    func sfSymbolPickerColorRenderingMode(_ colorMode: SymbolColorRenderingMode) -> some View {
        if colorMode == .flat {
            environment(\.symbolColorRenderingModeSetting, .flat)
        } else if colorMode == .gradient {
            environment(\.symbolColorRenderingModeSetting, .gradient)
        } else {
            self
        }
    }

    @ViewBuilder
    func sfSymbolPickerForegroundStyle(_ color: Color) -> some View {
        environment(\.symbolColorsSetting, SymbolColorsSetting(color: color))
    }

    @ViewBuilder
    func sfSymbolPickerForegroundStyle(_ primary: Color, _ secondary: Color) -> some View {
        environment(
            \.symbolColorsSetting,
             SymbolColorsSetting(primaryColor: primary, secondaryColor: secondary)
        )
    }

    @ViewBuilder
    func sfSymbolPickerForegroundStyle(_ primary: Color, _ secondary: Color, _ tertiary: Color) -> some View {
        environment(
            \.symbolColorsSetting,
             SymbolColorsSetting(primaryColor: primary, secondaryColor: secondary, tertiaryColor: tertiary)
        )
    }

    @ViewBuilder
    func sfSymbolPickerVariableValue(_ value: Double) -> some View {
        environment(\.symbolPickerVariableValue, value)
    }

    @available(iOS 26, macOS 26, *)
    @ViewBuilder
    func sfSymbolPickerVariableValueMode(_ variableValueMode: SymbolVariableValueMode) -> some View {
        if variableValueMode == .draw {
            environment(\.symbolPickerVariableValueModeSetting, .draw)
        } else if variableValueMode == .color {
            environment(\.symbolPickerVariableValueModeSetting, .color)
        } else {
            self
        }
    }

    @ViewBuilder
    func sfSymbolPickerPreviewUsesRenderingMode(_ isEnabled: Bool) -> some View {
        environment(\.symbolPickerPreviewUsesRenderingMode, isEnabled)
    }

    @ViewBuilder
    func sfSymbolPickerPreviewUsesVariableValue(_ isEnabled: Bool) -> some View {
        environment(\.symbolPickerPreviewUsesVariableValue, isEnabled)
    }
}
