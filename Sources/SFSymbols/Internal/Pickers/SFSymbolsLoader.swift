import SwiftUI

struct SFSymbolsLoader<Content: View>: View {
    @ViewBuilder let content: (SFSymbols) -> Content

    @State private var loadError: Error?
    @State private var symbols: SFSymbols?

    var body: some View {
        Group {
            if let loadError {
                ContentUnavailableView(
                    "Could not load symbols",
                    systemImage: "exclamationmark.triangle.fill",
                    description: Text(loadError.localizedDescription)
                )
            } else {
                ZStack {
                    content(symbols ?? .placeholder)
                        .opacity(symbols == nil ? 0 : 1)
                    if symbols == nil {
                        ContentUnavailableView {
                            ZStack {
                                // Add a hidden SF Symbol to ensure we can load the CoreGlyphs bundle.
                                Image(systemName: "tortoise")
                                    .opacity(0)
                                ProgressView()
                                    #if os(iOS)
                                    .scaleEffect(2)
                                    #elseif os(macOS)
                                    .padding()
                                    #endif
                            }
                        } description: {
                            Text("Loading...")
                                .padding(.top)
                        }
                    }
                }
            }
        }
        .task {
            do {
                symbols = try await SFSymbols()
            } catch {
                loadError = error
            }
        }
    }
}
