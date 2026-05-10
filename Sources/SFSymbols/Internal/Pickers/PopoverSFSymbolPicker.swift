import SwiftUI

struct PopoverSFSymbolPicker: View {
    @Binding var selection: String?
    let suggestedSymbols: [String]

    @State private var searchText = ""
    @State private var categoryFilter: SFSymbolCategoryFilter?
    @State private var symbolBackgroundSetting: SymbolBackgroundSetting = .default

    init(selection: Binding<String?>, suggestedSymbols: [String] = []) {
        self._selection = selection
        self.suggestedSymbols = suggestedSymbols
    }

    var body: some View {
        SFSymbolsLoader { symbols in
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    SearchField(searchText: $searchText)
                    #if !os(visionOS)
                    SettingsMenu(symbolBackgroundSetting: $symbolBackgroundSetting)
                    #endif
                }
                .padding([.horizontal, .top], 12)
                Divider()
                #if os(macOS) || os(visionOS)
                    .padding(.top, 9)
                #endif
                SFSymbolPickerGrid(
                    selection: $selection,
                    symbols: symbols.symbols,
                    suggestedSymbols: suggestedSymbols,
                    categoryFilter: selectedCategoryFilter,
                    searchText: searchText,
                    configuration: .modal
                )
                #if os(macOS) || os(visionOS)
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
            .frame(width: 360, height: 500)
            .foregroundStyle(Color.primary)
        }
    }
}

private extension PopoverSFSymbolPicker {
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
}

private struct SearchField: View {
    @Binding var searchText: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.placeholder)
            TextField("Search Symbols", text: $searchText, prompt: Text("Search Symbols"))
                .textFieldStyle(.plain)
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Capsule().fill(.ultraThinMaterial.opacity(0.85)))
        .overlay(Capsule().stroke(.separator, lineWidth: 1))
    }
}

#Preview {
    @Previewable @State var selection: String?

    PopoverSFSymbolPicker(selection: $selection)
}
