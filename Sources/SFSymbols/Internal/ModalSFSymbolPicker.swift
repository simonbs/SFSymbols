import SwiftUI

public struct ModalSFSymbolPicker: View {
    @State private var isLoading = true
    @State private var loadError: Error?
    @State private var symbols: SFSymbols?
    @Binding private var selection: String?
    @Environment(\.dismiss) private var dismiss

    public init(selection: Binding<String?>) {
        self._selection = selection
    }

    public var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ContentUnavailableView {
                        ZStack {
                            // Add a hidden SF Symbol to ensure we can load the CoreGlyphs bundle.
                            Image(systemName: "tortoise")
                                .opacity(0)
                            ProgressView()
                                .scaleEffect(2)
                        }
                    } description: {
                        Text("Loading...")
                            .padding(.top)
                    }
                } else if let loadError {
                    ContentUnavailableView(
                        "Could not load symbols",
                        systemImage: "exclamationmark.triangle.fill",
                        description: Text(loadError.localizedDescription)
                    )
                } else if let symbols {
                    SymbolPicker(selection: $selection, symbols: symbols)
                }
            }
            .background(BackgroundView())
            .navigationTitle("Symbols")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if #available(iOS 26, *) {
                        Button(role: .close) {
                            dismiss()
                        }
                    } else {
                        Button {
                            dismiss()
                        } label: {
                            Label("Close", systemImage: "xmark")
                                .labelStyle(.iconOnly)
                        }
                    }
                }
            }
        }
        .task {
            do {
                symbols = try await SFSymbols()
                isLoading = false
            } catch {
                loadError = error
                isLoading = false
            }
        }
    }
}

private extension ModalSFSymbolPicker {
    struct BackgroundView: View {
        @Environment(\.colorScheme) private var colorScheme
        private var backgroundStyle: some ShapeStyle {
            switch colorScheme {
            case .light:
                AnyShapeStyle(.background.secondary)
            case .dark:
                AnyShapeStyle(.background)
            @unknown default:
                AnyShapeStyle(.background.secondary)
            }
        }

        var body: some View {
            Rectangle()
                .fill(backgroundStyle)
                .ignoresSafeArea()
        }
    }
}

#Preview {
    @Previewable @State var selection: String?

    ModalSFSymbolPicker(selection: $selection)
}
