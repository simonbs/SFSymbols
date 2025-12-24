import SwiftUI

struct SheetSFSymbolPicker: View {
    @Binding var selection: String?

    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            SFSymbolsLoader { symbols in
                SFSymbolsView(
                    selection: $selection,
                    symbols: symbols,
                    searchText: searchText
                )
            }
            .background(BackgroundView())
            .navigationTitle("Symbols")
            .searchable(text: $searchText)
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
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
            #endif
        }
    }
}

private extension SheetSFSymbolPicker {
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

    SheetSFSymbolPicker(selection: $selection)
}
