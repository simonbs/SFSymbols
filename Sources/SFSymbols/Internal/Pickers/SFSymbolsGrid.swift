import SwiftUI

struct SFSymbolsGrid: View {
    let symbols: [SFSymbol]
    @Binding var selection: String?
    let edgePadding: CGFloat
    let preferredItemSize: CGSize
    let itemSpacing: CGFloat

    @State private var columns: [GridItem] = []
    @State private var tileHeight: CGFloat = 45
    @State private var symbolTileScale: CGFloat = 1

    var body: some View {
        LazyVGrid(columns: columns, spacing: itemSpacing) {
            ForEach(symbols) { symbol in
                Button {
                    selection = symbol.name
                } label: {
                    SFSymbolTile(
                        scale: symbolTileScale,
                        systemName: symbol.name,
                        isSelected: symbol.name == selection
                    )
                    .tint(.primary)
                    .frame(height: tileHeight)
                }
                .buttonStyle(.plain)
            }
        }
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.size.width
        } action: { newValue in
            let itemWidth = itemWidth(forContainerWidth: newValue)
            columns = [GridItem(.adaptive(minimum: itemWidth, maximum: itemWidth), spacing: itemSpacing)]
            tileHeight = round(itemWidth * preferredItemSize.height / preferredItemSize.width)
            symbolTileScale = itemWidth / preferredItemSize.width
        }
    }
}

private extension SFSymbolsGrid {
    private func itemWidth(forContainerWidth containerWidth: CGFloat) -> CGFloat {
        guard containerWidth > 0 else {
            return preferredItemSize.width
        }
        let availableWidth = containerWidth - edgePadding * 2
        let rawCount = (availableWidth + itemSpacing) / (preferredItemSize.width + itemSpacing)
        let itemCount = max(1, Int(floor(rawCount)))
        let totalSpacing = CGFloat(itemCount - 1) * itemSpacing
        return floor((availableWidth - totalSpacing) / CGFloat(itemCount))
    }
}
