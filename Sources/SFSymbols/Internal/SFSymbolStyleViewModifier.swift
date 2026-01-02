import SwiftUI

struct SFSymbolStyleViewModifier: ViewModifier {
    @Environment(\.symbolPickerRenderingMode) private var symbolPickerRenderingMode
    @Environment(\.symbolColorRenderingModeSetting) private var symbolColorRenderingModeSetting
    @Environment(\.symbolColorsSetting) private var symbolColorsSetting

    func body(content: Content) -> some View {
        content
            .symbolRenderingMode(symbolPickerRenderingMode)
            .symbolColorRenderingModeSetting(symbolColorRenderingModeSetting)
            .symbolColorsSetting(symbolColorsSetting)
    }
}
