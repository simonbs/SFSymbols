import SFSymbols
import SwiftUI

struct EmbeddedPickerDemoView: View {
    @State private var folderTitle = ""
    @State private var selectedSFSymbol = "folder"
    @State private var searchText = ""
    @State private var categoryFilter: SFSymbolCategoryFilter = .all
    @State private var symbols: SFSymbols?
    @State private var loadError: Error?
    @State private var searchTextFieldHeight: CGFloat = 0
    @State private var categoryFilterHeight: CGFloat = 0
    private var showsCategoryFilter: Bool {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    private var bottomScrollContentMargin: CGFloat {
        var result: CGFloat = 10 + 16
        if showsCategoryFilter {
            result += categoryFilterHeight
        }
        return result
    }

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: selectedSFSymbol)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 86, height: 86)
            TextField("Folder Name", text: $folderTitle)
                .textFieldStyle(.plain)
                .padding(.horizontal, 18)
                .frame(height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(.background)
                )
            ZStack {
                if let symbols {
                    VStack(spacing: 0) {
                        SFSymbolPickerGrid(
                            selection: $selectedSFSymbol,
                            symbols: symbols.symbols,
                            categoryFilter: categoryFilter,
                            searchText: searchText
                        )
                        .contentMargins(.top, searchTextFieldHeight + 16, for: .scrollContent)
                        .contentMargins(.top, searchTextFieldHeight, for: .scrollIndicators)
                        .contentMargins(.bottom, bottomScrollContentMargin, for: .scrollContent)
                        .contentMargins(.bottom, bottomScrollContentMargin, for: .scrollIndicators)
                        .contentMargins(.horizontal, 16, for: .scrollContent)
                    }
                    .clipShape(
                        SearchFieldAndGridClipShape(
                            edgePadding: 16,
                            capsuleHeight: searchTextFieldHeight
                        )
                    )
                }
                VStack(spacing: 0) {
                    SearchField(searchText: $searchText)
                        .padding(.horizontal, 16)
                        .onGeometryChange(for: CGFloat.self) { proxy in
                            proxy.size.height
                        } action: { newValue in
                            searchTextFieldHeight = newValue
                        }
                    Spacer()
                }
            }
            .padding(.top, 16)
            .overlay(alignment: .bottom) {
                if showsCategoryFilter, let symbols {
                    SFSymbolCategoryFilterPicker(
                        categories: symbols.categories.displayable,
                        selection: $categoryFilter
                    )
                    .onGeometryChange(for: CGFloat.self) { proxy in
                        proxy.size.height
                    } action: { newValue in
                        categoryFilterHeight = newValue
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 10)
                    .transition(.opacity.animation(.linear(duration: 0.15)))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.background)
            )
        }
        .padding()
        .sfSymbolPickerRenderingMode(.hierarchical)
        .sfSymbolPickerForegroundStyle(.primary, .blue, .gray)
        .background {
            Rectangle()
                .fill(.background.secondary)
                .ignoresSafeArea()
        }
        .navigationTitle("Embedded Picker")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .task {
            do {
                symbols = try await SFSymbols()
            } catch {
                loadError = error
            }
        }
    }
}

private struct SearchField: View {
    @Binding var searchText: String

    @Environment(\.displayScale) private var displayScale
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.placeholder)
            TextField("Search Symbols", text: $searchText, prompt: Text("Search Symbols"))
                .textFieldStyle(.plain)
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                    isFocused = true
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .tint(.secondary)
            }
        }
        .focused($isFocused)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .modifier(SearchFieldBackgroundViewModifier())
        .overlay(Capsule().stroke(.separator, lineWidth: 1 / displayScale))
    }
}

private struct SearchFieldBackgroundViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26, macOS 26, *) {
            #if os(iOS)
            content.glassEffect(.regular.tint(Color(uiColor: .secondarySystemBackground)), in: Capsule())
            #elseif os(macOS)
            content.glassEffect(.regular.tint(Color(nsColor: .controlBackgroundColor)), in: Capsule())
            #else
            content.background(Capsule().fill(.background.secondary))
            #endif
        } else {
            content.background(Capsule().fill(.background.secondary))
        }
    }
}

private struct SearchFieldAndGridClipShape: Shape {
    var edgePadding: CGFloat
    var capsuleHeight: CGFloat

    func path(in rect: CGRect) -> Path {
        let joinY = rect.minY + capsuleHeight / 2
        let capsuleRect = CGRect(
            x: rect.minX + edgePadding,
            y: rect.minY,
            width: rect.width - edgePadding * 2,
            height: capsuleHeight
        )
        let bodyRect = CGRect(
            x: rect.minX,
            y: joinY,
            width: rect.width,
            height: rect.maxY - joinY
        )
        var path = Path()
        path.addRect(bodyRect)
        path.addPath(Capsule().path(in: capsuleRect))
        return path
    }
}

#Preview {
    NavigationStack {
        EmbeddedPickerDemoView()
    }
}
