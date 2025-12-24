import SFSymbols
import SwiftUI

struct ContentView: View {
    @State private var selectedSFSymbol = "tortoise"

    var body: some View {
        NavigationStack {
            Form {
                SFSymbolPicker("Symbol", selection: $selectedSFSymbol)
                #if os(visionOS)
                    .tint(.primary)
                #endif
            }
            .navigationTitle("Example")
        }
    }
}

#Preview {
    ContentView()
}
