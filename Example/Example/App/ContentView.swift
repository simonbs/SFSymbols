import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink("Modal Picker") {
                        ModalPickerDemoView()
                    }
                } footer: {
                    Text("Present a picker modally or in a popover from a simple row.")
                }
                Section {
                    NavigationLink("Embedded Picker") {
                        EmbeddedPickerDemoView()
                    }
                } footer: {
                    Text("Embed the picker inside a form or detail screen to pick an icon inline.")
                }
            }
            .navigationTitle("Examples")
        }
    }
}

#Preview {
    ContentView()
}
