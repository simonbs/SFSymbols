import SwiftUI

struct CategoryFilterSafeAreaBarViewModifier<BarContent: View>: ViewModifier {
    let isEnabled: Bool
    @ViewBuilder let barContent: () -> BarContent

    func body(content: Content) -> some View {
        if #available(iOS 26, macOS 26, watchOS 26, visionOS 26, *) {
            content.safeAreaBar(edge: .bottom) {
                if isEnabled {
                    barContent()
                    #if os(iOS)
                        .padding(.horizontal, 28)
                    #elseif os(macOS) || os(visionOS)
                        .padding([.horizontal, .bottom])
                    #endif
                        .transition(.opacity.animation(.linear(duration: 0.15)))
                }
            }
        } else {
            content.safeAreaInset(edge: .bottom) {
                if isEnabled {
                    VStack(spacing: 0) {
                        Divider()
                        barContent()
                            .padding()
                    }
                    .background(.ultraThinMaterial)
                    .transition(.opacity.animation(.linear(duration: 0.15)))
                }
            }
        }
    }
}

extension String {
    var normalizedForSearch: String {
        trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
