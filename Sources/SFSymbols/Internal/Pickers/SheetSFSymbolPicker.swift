import SwiftUI

struct SheetSFSymbolPicker: View {
    @Binding var selection: String?
    let suggestedSymbols: [String]

    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var categoryFilter: SFSymbolCategoryFilter?
    @State private var symbolBackgroundSetting: SymbolBackgroundSetting = .default

    init(selection: Binding<String?>, suggestedSymbols: [String] = []) {
        self._selection = selection
        self.suggestedSymbols = suggestedSymbols
    }

    var body: some View {
        NavigationStack {
            SFSymbolsLoader { symbols in
                SFSymbolPickerGrid(
                    selection: $selection,
                    symbols: symbols.symbols,
                    suggestedSymbols: suggestedSymbols,
                    categoryFilter: selectedCategoryFilter,
                    searchText: searchText,
                    configuration: .modal
                )
                #if os(macOS)
                .contentMargins(.top, 8, for: .scrollContent)
                #endif
                .modifier(CategoryFilterSafeAreaBarViewModifier(isEnabled: searchText.normalizedForSearch.isEmpty) {
                    SFSymbolCategoryFilterPicker(
                        categories: symbols.categories.displayable,
                        suggestedSymbols: suggestedSymbols,
                        selection: categoryFilterSelection
                    )
                    .transition(.opacity.animation(.linear(duration: 0.1)))
                })
                .environment(\.symbolBackgroundSetting, symbolBackgroundSetting)
            }
            .background(BackgroundView())
            .navigationTitle("Symbols")
            .searchable(text: $searchText, prompt: Text("Search Symbols"))
            .foregroundStyle(Color.primary)
            #if canImport(UIKit)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        SettingsMenu(symbolBackgroundSetting: $symbolBackgroundSetting)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        if #available(iOS 26, visionOS 26, *) {
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
    private var selectedCategoryFilter: SFSymbolCategoryFilter {
        guard let categoryFilter else {
            return suggestedSymbols.isEmpty ? .all : .suggested
        }
        if categoryFilter == .suggested && suggestedSymbols.isEmpty {
            return .all
        }
        return categoryFilter
    }

    private var categoryFilterSelection: Binding<SFSymbolCategoryFilter> {
        Binding {
            selectedCategoryFilter
        } set: { newValue in
            categoryFilter = newValue
        }
    }

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
