<div align="center">
  <img src="recording.gif" width="300" />
  <h1>SFSymbols</h1>
  <h3>SFSymbols gives you a ready-to-use symbol picker for SwiftUI and an API for reading the SF Symbols catalog.</h3>
  <h4>Use SFSymbols to let users pick symbols in-app, or to build your own symbol browsing UI.</h4>

  [![SwiftLint](https://github.com/simonbs/SFSymbols/actions/workflows/swiftlint.yml/badge.svg)](https://github.com/simonbs/SFSymbols/actions/workflows/swiftlint.yml)
  [![Build](https://github.com/simonbs/SFSymbols/actions/workflows/build.yml/badge.svg)](https://github.com/simonbs/SFSymbols/actions/workflows/build.yml)
  [![Build Example Project](https://github.com/simonbs/SFSymbols/actions/workflows/build_example_project.yml/badge.svg)](https://github.com/simonbs/SFSymbols/actions/workflows/build_example_project.yml)
</div>

<hr/>

- [🚀 Getting Started](#-getting-started)
  - [Add the SFSymbols Swift Package](#add-the-sfsymbols-swift-package)
  - [Use SFSymbolPicker](#use-sfsymbolpicker)
  - [Present the Picker With .sfSymbolPicker(...)](#present-the-picker-with-sfsymbolpicker)
  - [Load and Browse Symbols With SFSymbols](#load-and-browse-symbols-with-sfsymbols)
- [📱 Example Project](#-example-project)

<hr/>

## 🚀 Getting Started

This section walks through adding SFSymbols and using the three primary APIs.

### Add the SFSymbols Swift Package

Add SFSymbols to your Xcode project or Swift package.

```swift
let package = Package(
    dependencies: [
        .package(url: "https://github.com/simonbs/SFSymbols.git", from: "1.0.0")
    ]
)
```

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

Open the example app in `Example/Example.xcodeproj` to see `SFSymbolPicker` in a simple form.
