import SwiftUI

struct CategoryFilterPicker: View {
    let categories: [SFSymbolCategory]
    @Binding var selection: CategoryFilter

    @State private var didScrollToSelection = false
    private var filters: [CategoryFilter] {
        [.all] + categories.map { .category($0) }
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    ForEach(filters) { filter in
                        Button {
                            selection = filter
                        } label: {
                            filter.image
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.primary.opacity(selection == filter ? 1 : 0.8))
                                .frame(width: 35, height: 35)
                        }
                        .buttonStyle(.plain)
                        .id(filter)
                        .tint(.primary)
                        .frame(width: 44, height: 44)
                        .anchorPreference(
                            key: CategoryFilterItemBoundsKey.self,
                            value: .bounds
                        ) { [filter: $0] }
                    }
                }
                .backgroundPreferenceValue(CategoryFilterItemBoundsKey.self) { anchors in
                    GeometryReader { proxy in
                        if let anchor = anchors[selection] {
                            let rect = proxy[anchor]
                            SelectionIndicator()
                                .position(x: rect.midX, y: rect.midY)
                                .animation(.snappy(duration: 0.18), value: selection)
                        }
                    }
                }
            }
            .onChange(of: selection, initial: true) { _, newSelection in
                if !didScrollToSelection {
                    didScrollToSelection = true
                    proxy.scrollTo(newSelection, anchor: .center)
                }
            }
        }
        .clipShape(.capsule)
        .scrollIndicators(.hidden)
        .frame(height: 44)
        .coordinateSpace(name: "CategoryFilterPicker")
        .background {
            if #available(iOS 26, macOS 26, *) {
                Color.clear
                    .glassEffect(.regular.interactive(), in: .capsule)
            } else {
                Capsule()
                    .fill(.bar)
                    .shadow(color: .black.opacity(0.1), radius: 4)
            }
        }
        .padding(.horizontal, 27)
    }
}

private extension CategoryFilterPicker {
    struct SelectionIndicator: View {
        @Environment(\.colorScheme) private var colorScheme
        private var selectionIndicatorColor: Color {
            switch colorScheme {
            case .dark:
                .white.opacity(0.15)
            case .light:
                fallthrough
            @unknown default:
                .black.opacity(0.1)
            }
        }

        var body: some View {
            Circle()
                .foregroundStyle(selectionIndicatorColor)
                .frame(width: 35, height: 35)
                .allowsHitTesting(false)
        }
    }
}

nonisolated private struct CategoryFilterItemBoundsKey: PreferenceKey {
    nonisolated(unsafe) static let defaultValue: [CategoryFilter: Anchor<CGRect>] = [:]

    static func reduce(
        value: inout [CategoryFilter: Anchor<CGRect>],
        nextValue: () -> [CategoryFilter: Anchor<CGRect>]
    ) {
        value.merge(nextValue()) { $1 }
    }
}
