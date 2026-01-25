import SwiftUI

private struct SymbolPickerRenderingModeEnvironmentKey: EnvironmentKey {
    static let defaultValue: SymbolRenderingMode = .monochrome
}

// swiftlint:disable:next type_name
private struct SymbolColorRenderingModeSettingEnvironmentKey: EnvironmentKey {
    static let defaultValue: SymbolColorRenderingModeSetting = .flat
}

private struct SymbolColorsSettingEnvironmentKey: EnvironmentKey {
    static let defaultValue = SymbolColorsSetting()
}

private struct SymbolBackgroundSettingEnvironmentKey: EnvironmentKey {
    static let defaultValue: SymbolBackgroundSetting = .default
}

private struct SymbolPickerVariableValueEnvironmentKey: EnvironmentKey {
    static let defaultValue: Double = 1
}

// swiftlint:disable:next type_name
private struct SymbolPickerVariableValueModeEnvironmentKey: EnvironmentKey {
    static let defaultValue: SymbolVariableValueModeSetting = .color
}

// swiftlint:disable:next type_name
private struct SymbolPickerPreviewUsesRenderingModeEnvironmentKey: EnvironmentKey {
    static let defaultValue = false
}

// swiftlint:disable:next type_name
private struct SymbolPickerPreviewUsesVariableValueEnvironmentKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var symbolPickerRenderingMode: SymbolRenderingMode {
        get { self[SymbolPickerRenderingModeEnvironmentKey.self] }
        set { self[SymbolPickerRenderingModeEnvironmentKey.self] = newValue }
    }

    var symbolColorRenderingModeSetting: SymbolColorRenderingModeSetting {
        get { self[SymbolColorRenderingModeSettingEnvironmentKey.self] }
        set { self[SymbolColorRenderingModeSettingEnvironmentKey.self] = newValue }
    }

    var symbolColorsSetting: SymbolColorsSetting {
        get { self[SymbolColorsSettingEnvironmentKey.self] }
        set { self[SymbolColorsSettingEnvironmentKey.self] = newValue }
    }

    var symbolBackgroundSetting: SymbolBackgroundSetting {
        get { self[SymbolBackgroundSettingEnvironmentKey.self] }
        set { self[SymbolBackgroundSettingEnvironmentKey.self] = newValue }
    }

    var symbolPickerVariableValue: Double {
        get { self[SymbolPickerVariableValueEnvironmentKey.self] }
        set { self[SymbolPickerVariableValueEnvironmentKey.self] = newValue }
    }

    var symbolPickerVariableValueModeSetting: SymbolVariableValueModeSetting {
        get { self[SymbolPickerVariableValueModeEnvironmentKey.self] }
        set { self[SymbolPickerVariableValueModeEnvironmentKey.self] = newValue }
    }

    var symbolPickerPreviewUsesRenderingMode: Bool {
        get { self[SymbolPickerPreviewUsesRenderingModeEnvironmentKey.self] }
        set { self[SymbolPickerPreviewUsesRenderingModeEnvironmentKey.self] = newValue }
    }

    var symbolPickerPreviewUsesVariableValue: Bool {
        get { self[SymbolPickerPreviewUsesVariableValueEnvironmentKey.self] }
        set { self[SymbolPickerPreviewUsesVariableValueEnvironmentKey.self] = newValue }
    }
}
