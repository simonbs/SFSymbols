import SwiftUI

struct PopoverSFSymbolPicker: View {
    @Binding var selection: String?

    @State private var searchText = ""
    @State private var categoryFilter: SFSymbolCategoryFilter = .all
    @State private var symbolBackgroundSetting: SymbolBackgroundSetting = .default

    var body: some View {
        SFSymbolsLoader { symbols in
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    SearchField(searchText: $searchText)
                    SettingsMenu(symbolBackgroundSetting: $symbolBackgroundSetting)
                }
                .padding([.horizontal, .top], 12)
                Divider()
                SFSymbolPickerGrid(
                    selection: $selection,
                    symbols: symbols.symbols,
                    categoryFilter: categoryFilter,
                    searchText: searchText
                )
                .modifier(CategoryFilterSafeAreaBarViewModifier(isEnabled: searchText.normalizedForSearch.isEmpty) {
                    SFSymbolCategoryFilterPicker(
                        categories: symbols.categories.displayable,
                        selection: $categoryFilter
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
