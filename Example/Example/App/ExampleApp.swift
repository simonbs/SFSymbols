import SwiftUI

@main
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
            #if os(macOS) || os(visionOS)
                .frame(
                    minWidth: 420,
                    idealWidth: 560,
                    maxWidth: 700,
                    minHeight: 520,
                    idealHeight: 680,
                    maxHeight: 900
                )
            #endif
        }
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        #endif
        #if os(macOS) || os(visionOS)
        .windowResizability(.contentSize)
        #endif
    }
}
