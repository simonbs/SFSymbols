import SwiftUI

struct SheetSFSymbolPicker: View {
    @Binding var selection: String?

    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var categoryFilter: SFSymbolCategoryFilter = .all
    @State private var symbolBackgroundSetting: SymbolBackgroundSetting = .default

    var body: some View {
        NavigationStack {
            SFSymbolsLoader { symbols in
                SFSymbolPickerGrid(
                    selection: $selection,
                    symbols: symbols.symbols,
                    categoryFilter: categoryFilter,
                    searchText: searchText,
                    configuration: .modal
                )
                #if os(macOS)
                .contentMargins(.top, 8, for: .scrollContent)
                #endif
                .modifier(CategoryFilterSafeAreaBarViewModifier(isEnabled: searchText.normalizedForSearch.isEmpty) {
                    SFSymbolCategoryFilterPicker(
                        categories: symbols.categories.displayable,
                        selection: $categoryFilter
                    )
                    .transition(.opacity.animation(.linear(duration: 0.1)))
                })
                .environment(\.symbolBackgroundSetting, symbolBackgroundSetting)
            }
            .background(BackgroundView())
            .navigationTitle("Symbols")
            .searchable(text: $searchText, prompt: Text("Search Symbols"))
            .foregroundStyle(Color.primary)
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        SettingsMenu(symbolBackgroundSetting: $symbolBackgroundSetting)
                    }
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
