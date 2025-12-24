import SwiftUI

@main
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
            #if os(macOS) || os(visionOS)
                .frame(
                    minWidth: 400,
                    idealWidth: 500,
                    maxWidth: 600,
                    minHeight: 300,
                    idealHeight: 375,
                    maxHeight: 450
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
