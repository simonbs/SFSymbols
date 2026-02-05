<div align="center">
  <img src="recording.gif" />
  <h1>SFSymbols</h1>
  <h3>SFSymbols provides an SF Symbol picker and a simple API for accessing the SF Symbols catalog.</h3>
  <h4>Use it to let users choose symbols in-app or to build your own symbol browser.</h4>

  [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fsimonbs%2FSFSymbols%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/simonbs/SFSymbols)
  [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fsimonbs%2FSFSymbols%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/simonbs/SFSymbols)\
  [![SwiftLint](https://github.com/simonbs/SFSymbols/actions/workflows/swiftlint.yml/badge.svg)](https://github.com/simonbs/SFSymbols/actions/workflows/swiftlint.yml)
  [![Build](https://github.com/simonbs/SFSymbols/actions/workflows/build.yml/badge.svg)](https://github.com/simonbs/SFSymbols/actions/workflows/build.yml)
  [![Build Example Project](https://github.com/simonbs/SFSymbols/actions/workflows/build_example_project.yml/badge.svg)](https://github.com/simonbs/SFSymbols/actions/workflows/build_example_project.yml)
</div>

<hr/>

- [🚀 Getting Started](#-getting-started)
  - [Add the SFSymbols Swift Package](#add-the-sfsymbols-swift-package)
  - [Picker Options](#picker-options)
  - [Use SFSymbolPicker](#use-sfsymbolpicker)
  - [Use SFSymbolPickerGrid (Embedded)](#use-sfsymbolpickergrid-embedded)
  - [Present the Picker With .sfSymbolPicker(...)](#present-the-picker-with-sfsymbolpicker)
  - [Configure Picker Settings](#configure-picker-settings)
  - [Load and Browse Symbols With SFSymbols](#load-and-browse-symbols-with-sfsymbols)
- [📱 Example Project](#-example-project)

<hr/>

## 🚀 Getting Started

This section walks through adding SFSymbols and using the primary APIs.

### Add the SFSymbols Swift Package

Add SFSymbols to your Xcode project or Swift package.

```swift
let package = Package(
    dependencies: [
        .package(url: "https://github.com/simonbs/SFSymbols.git", from: "1.0.0")
    ]
)
```

### Picker Options

Use one of these entry points depending on how much control you need:

- `SFSymbolPicker` for a ready-made labeled row that presents a modal picker.
- `.sfSymbolPicker` for attaching the modal picker to your own button or custom row.
- `SFSymbolPickerGrid` for embedding the grid in your own layout with custom search and filters.

### Use SFSymbolPicker

`SFSymbolPicker` is a SwiftUI view that presents a labeled row with a button showing the current symbol.

```swift
import SFSymbols
import SwiftUI

struct ContentView: View {
    @State private var selectedSymbol = "tortoise"

    var body: some View {
        Form {
            SFSymbolPicker("Symbol", selection: $selectedSymbol)
        }
    }
}
```

`SFSymbolPicker` accepts both optional and non-optional bindings. Optional bindings let you clear the selection.

### Use SFSymbolPickerGrid (Embedded)

`SFSymbolPickerGrid` renders the symbol grid and applies filtering based on
the search text and category filter values you provide. It does not ship a
search field or category UI, so you can compose those yourself.

Use it together with your own search UI and the public `SFSymbolCategoryFilterPicker`.

```swift
import SFSymbols
import SwiftUI

struct ContentView: View {
    @State private var title = ""
    @State private var selectedSymbol = "folder"
    @State private var searchText = ""
    @State private var categoryFilter: SFSymbolCategoryFilter = .all
    @State private var symbols: SFSymbols?
    private let gridConfiguration = SFSymbolPickerGrid.Configuration(edgePadding: 16)

    var body: some View {
        VStack {
            TextField("Title", text: $title)
            TextField("Search Symbols", text: $searchText)
            if let symbols {
                SFSymbolCategoryFilterPicker(
                    categories: symbols.categories.displayable,
                    selection: $categoryFilter
                )
                SFSymbolPickerGrid(
                    selection: $selectedSymbol,
                    symbols: symbols.symbols,
                    categoryFilter: categoryFilter,
                    searchText: searchText,
                    configuration: gridConfiguration
                )
            }
        }
        .task {
            symbols = try? await SFSymbols()
        }
    }
}
```

`SFSymbolPickerGrid` accepts both optional and non-optional selection bindings.
Use `SFSymbolPickerGrid.Configuration` to control padding, spacing, and item sizing.

### Present the Picker With .sfSymbolPicker(...)

Use the view modifier when you want full control over the button or the presentation trigger.

```swift
import SFSymbols
import SwiftUI

struct ContentView: View {
    @State private var isPresented = false
    @State private var selectedSymbol: String?

    var body: some View {
        Button {
            isPresented = true
        } label: {
            Label("Pick a Symbol", systemImage: selectedSymbol ?? "questionmark")
        }
        .sfSymbolPicker(isPresented: $isPresented, selection: $selectedSymbol)
    }
}
```

`.sfSymbolPicker` can be attached to any view, including images, list rows, or custom buttons.

### Configure Picker Settings

The picker reads its configuration from SwiftUI environment values. These settings control the
appearance of the symbols shown in the picker, and you can set them anywhere in the view tree
with the provided view modifiers.

```swift
SFSymbolPicker("Symbol", selection: $selectedSymbol)
    .sfSymbolPickerRenderingMode(.hierarchical)
    .sfSymbolPickerForegroundStyle(.primary, .blue, .secondary)
    .sfSymbolPickerVariableValue(0.6)
    .sfSymbolPickerVariableValueMode(.color)
    .sfSymbolPickerPreviewUsesRenderingMode(true)
    .sfSymbolPickerPreviewUsesVariableValue(true)
```

Available settings:

- `.sfSymbolPickerRenderingMode(_:)` sets the rendering mode for the symbols. Default is `.monochrome`.
  Supported values: `.monochrome`, `.hierarchical`, `.palette`, and `.multicolor`.
- `.sfSymbolPickerColorRenderingMode(_:)` specifies whether the symbols are rendered with gradient colors.
  Available on iOS 26 and macOS 26. Supported values: `.flat` and `.gradient`.
- `.sfSymbolPickerForegroundStyle(...)` sets primary, secondary, and tertiary color applied to symbols.
- `.sfSymbolPickerVariableValue(_:)` sets the variable value for variable symbols. Default is `1`.
- `.sfSymbolPickerVariableValueMode(_:)` selects whether the variable value affects draw or color.
  Available on iOS 26 and macOS 26. Supported values: `.draw` and `.color`. Default is `.color`.
- `.sfSymbolPickerPreviewUsesRenderingMode(_:)` defines whether the same appearance
  settings are applied to the preview inside `SFSymbolPicker`. Default is `false`.
- `.sfSymbolPickerPreviewUsesVariableValue(_:)` defines whether the same variable value
  settings are applied to the preview inside `SFSymbolPicker`. Default is `false`.

### Load and Browse Symbols With SFSymbols

`SFSymbols` loads the system catalog asynchronously. Use it to build custom filters, category views, or search.

```swift
import SFSymbols
import SwiftUI

struct SymbolBrowser: View {
    @State private var symbols: SFSymbols?

    var body: some View {
        List {
            if let symbols {
                ForEach(symbols.categories) { category in
                    Section(category.key) {
                        ForEach(category.symbols) { symbol in
                            Label(symbol.name, systemImage: symbol.name)
                        }
                    }
                }
            }
        }
        .task {
            symbols = try? await SFSymbols()
        }
    }
}
```

`SFSymbols` exposes the full list of symbols and their categories.

```swift
let symbols = try await SFSymbols()
let allSymbols = symbols.symbols
let categories = symbols.categories
```

Each `SFSymbol` includes its `name`, `searchTerms`, and `categories`, so you can build your own search and filtering UI.

## 📱 Example Project

Open the example app in `Example/Example.xcodeproj` to see both modal and embedded picker examples.
