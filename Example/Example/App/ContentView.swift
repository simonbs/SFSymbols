import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Modal Picker") {
                    ModalPickerDemoView()
                }
                NavigationLink("Embedded Picker") {
                    EmbeddedPickerDemoView()
                }
            }
            .navigationTitle("Examples")
        }
    }
}

#Preview {
    ContentView()
}
