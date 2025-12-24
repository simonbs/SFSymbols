import SwiftUI

struct PopoverSFSymbolPicker: View {
    @Binding var selection: String?

    @State private var searchText = ""

    var body: some View {
        SFSymbolsLoader { symbols in
            SFSymbolsView(
                selection: $selection,
                symbols: symbols,
                searchText: searchText
            )
            .modifier(SearchSafeAreaBarViewModifier {
                TextField("Search", text: $searchText, prompt: Text("Search"))
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(.ultraThinMaterial.opacity(0.85)))
                    .overlay(Capsule().stroke(.separator, lineWidth: 1))
            })
        }
        .frame(width: 360, height: 500)
    }
}

private struct SearchSafeAreaBarViewModifier<SearchBar: View>: ViewModifier {
    @ViewBuilder let searchBar: () -> SearchBar

    func body(content: Content) -> some View {
        if #available(iOS 26, macOS 26, *) {
            content.safeAreaBar(edge: .top) {
                searchBar()
                    .padding([.horizontal, .top])
            }
        } else {
            content.safeAreaInset(edge: .top) {
                VStack {
                    searchBar()
                        .padding([.horizontal, .top])
                        .padding(.bottom, 8)
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
