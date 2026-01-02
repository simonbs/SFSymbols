import SwiftUI

public struct SFSymbolPicker: View {
    private let titleResource: LocalizedStringResource
    @Binding private var selection: String?
    @State private var isPresented = false
    @Environment(\.symbolPickerPreviewUsesRenderingMode) private var previewUsesRenderingMode
    @Environment(\.symbolPickerPreviewUsesVariableValue) private var previewUsesVariableValue
    @Environment(\.symbolPickerVariableValueModeSetting) private var variableValueModeSetting
    @Environment(\.symbolPickerVariableValue) private var symbolPickerVariableValue

    public init(
        _ titleResource: LocalizedStringResource,
        selection: Binding<String?>
    ) {
        self.titleResource = titleResource
        self._selection = selection
    }

    public init(
        _ titleResource: LocalizedStringResource,
        selection: Binding<String>
    ) {
        self.titleResource = titleResource
        self._selection = Binding {
            selection.wrappedValue
        } set: { newValue in
            selection.wrappedValue = newValue ?? selection.wrappedValue
        }
    }

    public var body: some View {
        LabeledContent {
            Button {
                isPresented = true
            } label: {
                Group {
                    if let selection {
                        Group {
                            if previewUsesRenderingMode && previewUsesVariableValue {
                                Image(systemName: selection, variableValue: symbolPickerVariableValue)
                                    .symbolVariableValueModeSetting(variableValueModeSetting)
                                    .modifier(SFSymbolStyleViewModifier())
                            } else if previewUsesRenderingMode {
                                Image(systemName: selection)
                                    .modifier(SFSymbolStyleViewModifier())
                            } else if previewUsesVariableValue {
                                Image(systemName: selection, variableValue: symbolPickerVariableValue)
                                    .symbolVariableValueModeSetting(variableValueModeSetting)
                                    .foregroundStyle(.tint)
                            } else {
                                Image(systemName: selection)
                                    .foregroundStyle(.tint)
                            }
                        }
                        .font(.system(size: 18))
                    } else {
                        Text("Select...")
                    }
                }
                .foregroundStyle(Color.accentColor)
                .frame(width: 30, height: 30)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        } label: {
            Text(titleResource)
        }
        .sfSymbolPicker(
            isPresented: $isPresented,
            selection: $selection
        )
    }
}

#Preview {
    @Previewable @State var selection = "tortoise"

    Form {
        SFSymbolPicker("Symbol", selection: $selection)
    }
}
