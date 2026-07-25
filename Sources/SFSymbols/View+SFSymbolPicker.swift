import SwiftUI

public extension View {
    func sfSymbolPicker(
        isPresented: Binding<Bool>,
        selection: Binding<String?>,
        suggestedSymbols: [String] = []
    ) -> some View {
        modifier(
            SFSymbolPickerViewModifier(
                isPresented: isPresented,
                selection: selection,
                suggestedSymbols: suggestedSymbols
            )
        )
    }
}

private struct SFSymbolPickerViewModifier: ViewModifier {
    @Binding var isPresented: Bool
    @Binding var selection: String?
    let suggestedSymbols: [String]

    func body(content: Content) -> some View {
        #if os(macOS) || os(visionOS)
        content.popover(isPresented: $isPresented, arrowEdge: .top) {
            PopoverSFSymbolPicker(selection: $selection, suggestedSymbols: suggestedSymbols)
                .tint(nil)
        }
        #else
        content.sheet(isPresented: $isPresented) {
            SheetSFSymbolPicker(selection: $selection, suggestedSymbols: suggestedSymbols)
                .tint(nil)
        }
        #endif
    }
}
