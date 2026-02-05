import SFSymbols
import SwiftUI

struct ModalPickerDemoView: View {
    @State private var selectedSFSymbol = "heart"
    @State private var renderingMode: SymbolRenderingModeSetting = .hierarchical
    @State private var primaryColor: Color = .primary
    @State private var secondaryColor: Color = .blue
    @State private var tertiaryColor: Color = .gray
    @State private var isGradientEnabled = false
    @State private var variableValueMode: SymbolVariableValueModeSetting = .draw
    @State private var variableValue: Double = 100
    @State private var previewUsesRenderingMode = false
    @State private var previewUsesVariableValue = false

    var body: some View {
        Form {
            Section {
                SFSymbolPicker("Symbol", selection: $selectedSFSymbol)
                    #if os(visionOS)
                    .tint(.primary)
                    #endif
                    .sfSymbolPickerRenderingMode(SymbolRenderingMode(renderingMode))
                    .backportedSFSymbolPickerColorRenderingMode(isGradientEnabled ? .gradient : .flat)
                    .sfSymbolPickerForegroundStyle(primaryColor, secondaryColor, tertiaryColor)
                    .sfSymbolPickerVariableValue(variableValue / 100)
                    .backportedSFSymbolPickerVariableValueMode(variableValueMode)
                    .sfSymbolPickerPreviewUsesRenderingMode(previewUsesRenderingMode)
                    .sfSymbolPickerPreviewUsesVariableValue(previewUsesVariableValue)
            }
            #if os(macOS)
            Divider()
                .frame(maxWidth: 200)
                .padding(.vertical)
            #endif
            Section {
                Picker(selection: $renderingMode) {
                    ForEach(SymbolRenderingModeSetting.allCases) { setting in
                        Text(setting.title)
                    }
                } label: {
                    Text("Rendering Mode")
                }
                LabeledContent {
                    if renderingMode == .palette {
                        HStack {
                            ColorPicker("Primary Color", selection: $primaryColor)
                                .labelsHidden()
                            ColorPicker("Secondary Color", selection: $secondaryColor)
                                .labelsHidden()
                            ColorPicker("Tertiary Color", selection: $tertiaryColor)
                                .labelsHidden()
                        }
                    } else {
                        ColorPicker("Color", selection: $primaryColor)
                            .labelsHidden()
                    }
                } label: {
                    if renderingMode == .palette {
                        Text("Colors")
                    } else {
                        Text("Color")
                    }
                }
                if #available(iOS 26, macOS 26, *) {
                    Toggle(isOn: $isGradientEnabled) {
                        Text("Gradient")
                    }
                }
            }
            #if os(macOS)
            Divider()
                .frame(maxWidth: 200)
                .padding(.vertical)
            #endif
            Section {
                Picker(selection: $variableValueMode) {
                    ForEach(SymbolVariableValueModeSetting.allCases) { setting in
                        Text(setting.title)
                    }
                } label: {
                    Text("Variable Value Mode")
                }
                LabeledContent {
                    HStack {
                        Slider(value: $variableValue, in: 0 ... 100)
                            .frame(width: 200)
                        ZStack {
                            Text("888%")
                                .opacity(0)
                            Text("\(Int(round(variableValue)))%")
                        }
                        .monospacedDigit()
                    }
                } label: {
                    Text("Variable Value")
                }
            }
            #if os(macOS)
            Divider()
                .frame(maxWidth: 200)
                .padding(.vertical)
            #endif
            Section {
                Toggle("Preview Uses Rendering Mode", isOn: $previewUsesRenderingMode)
                Toggle("Preview Uses Variable Value", isOn: $previewUsesVariableValue)
            }
        }
        .navigationTitle("Modal Picker")
    }
}

#Preview {
    NavigationStack {
        ModalPickerDemoView()
    }
}
