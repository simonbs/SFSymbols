import SwiftUI

struct PopoverSFSymbolPicker: View {
    @Binding var selection: String?

    @State private var searchText = ""
    @FocusState private var isSearchedFocused: Bool

    var body: some View {
        SFSymbolsLoader { symbols in
            SFSymbolsView(
                selection: $selection,
                symbols: symbols,
                searchText: searchText
            )
            .modifier(SearchSafeAreaBarViewModifier {
                HStack(spacing: 4) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.placeholder)
                    TextField("Search", text: $searchText, prompt: Text("Search"))
                        .textFieldStyle(.plain)
                        .focused($isSearchedFocused)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Capsule().fill(.ultraThinMaterial.opacity(0.85)))
                .overlay(Capsule().stroke(.separator, lineWidth: 1))
            })
        }
        .frame(width: 360, height: 500)
        #if os(macOS)
        .onAppear {
            isSearchedFocused = true
        }
        #endif
    }
}

private struct SearchSafeAreaBarViewModifier<BarContent: View>: ViewModifier {
    @ViewBuilder let barContent: () -> BarContent

    func body(content: Content) -> some View {
        if #available(iOS 26, macOS 26, *) {
            content.safeAreaBar(edge: .top) {
                barContent()
                    .padding([.horizontal, .top])
            }
        } else {
            content.safeAreaInset(edge: .top) {
                VStack(spacing: 0) {
                    barContent()
                        .padding()
                    Divider()
                }
                .background(.ultraThinMaterial)
            }
        }
    }
}

#Preview {
    @Previewable @State var selection: String?

    PopoverSFSymbolPicker(selection: $selection)
}
