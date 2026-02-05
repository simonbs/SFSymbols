import SwiftUI

struct ContentView: View {
    private enum Example: Hashable {
        case modalPicker
        case embeddedPicker
    }

    @State private var selection: Example?

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                Section {
                    NavigationLink("Modal Picker", value: Example.modalPicker)
                } footer: {
                    Text("Present a picker modally or in a popover from a simple row.")
                }
                Section {
                    NavigationLink("Embedded Picker", value: Example.embeddedPicker)
                } footer: {
                    Text("Embed the picker inside a form or detail screen to pick an icon inline.")
                }
            }
            .navigationTitle("Examples")
        } detail: {
            switch selection {
            case .modalPicker:
                ModalPickerDemoView()
            case .embeddedPicker:
                EmbeddedPickerDemoView()
            case nil:
                Text("Select an example.")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationSplitViewStyle(.balanced)
        .onAppear {
            #if os(macOS)
            selection = .modalPicker
            #endif
        }
    }
}

#Preview {
    ContentView()
}
