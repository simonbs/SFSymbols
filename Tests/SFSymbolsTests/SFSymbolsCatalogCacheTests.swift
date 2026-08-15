import Foundation
@testable import SFSymbols
import XCTest

final class SFSymbolsCatalogCacheTests: XCTestCase {
    func testDiskCacheHitBypassesLoaderForSameOSVersion() async throws {
        let directory = try temporaryCacheDirectory()
        let symbols = Self.symbols(prefix: "cached")
        let writer = SFSymbolsCatalogCache(directory: directory, osVersion: "macOS-26.0.0")

        _ = try await writer.symbols {
            symbols
        }

        let loader = LoaderProbe()
        let reader = SFSymbolsCatalogCache(directory: directory, osVersion: "macOS-26.0.0")
        let cachedSymbols = try await reader.symbols {
            try await loader.load()
        }

        XCTAssertEqual(cachedSymbols.symbols, symbols.symbols)
        XCTAssertEqual(cachedSymbols.categories, symbols.categories)
        let callCount = await loader.numberOfCalls()
        XCTAssertEqual(callCount, 0)
    }

    func testDifferentOSVersionBypassesStaleCache() async throws {
        let directory = try temporaryCacheDirectory()
        let staleSymbols = Self.symbols(prefix: "stale")
        let currentSymbols = Self.symbols(prefix: "current")
        let writer = SFSymbolsCatalogCache(directory: directory, osVersion: "macOS-26.0.0")

        _ = try await writer.symbols {
            staleSymbols
        }

        let loader = LoaderProbe(result: currentSymbols)
        let reader = SFSymbolsCatalogCache(directory: directory, osVersion: "macOS-26.1.0")
        let loadedSymbols = try await reader.symbols {
            try await loader.load()
        }

        XCTAssertEqual(loadedSymbols.symbols, currentSymbols.symbols)
        XCTAssertEqual(loadedSymbols.categories, currentSymbols.categories)
        let callCount = await loader.numberOfCalls()
        XCTAssertEqual(callCount, 1)
    }

    func testConcurrentFirstLoadsShareLoaderResult() async throws {
        let directory = try temporaryCacheDirectory()
        let symbols = Self.symbols(prefix: "shared")
        let loader = LoaderProbe(result: symbols, delay: .milliseconds(50))
        let cache = SFSymbolsCatalogCache(directory: directory, osVersion: "macOS-26.0.0")

        async let firstSymbols = cache.symbols {
            try await loader.load()
        }
        async let secondSymbols = cache.symbols {
            try await loader.load()
        }
        let (first, second) = try await (firstSymbols, secondSymbols)

        XCTAssertEqual(first.symbols, symbols.symbols)
        XCTAssertEqual(second.symbols, symbols.symbols)
        let callCount = await loader.numberOfCalls()
        XCTAssertEqual(callCount, 1)
    }

    func testSuccessfulWriteOverwritesSingleCacheFile() async throws {
        let directory = try temporaryCacheDirectory()
        let unrelatedFileURL = directory.appendingPathComponent("metadata.json")
        try Data().write(to: unrelatedFileURL)

        let firstCache = SFSymbolsCatalogCache(directory: directory, osVersion: "macOS-26.0.0")
        _ = try await firstCache.symbols {
            Self.symbols(prefix: "stale")
        }

        let secondCache = SFSymbolsCatalogCache(directory: directory, osVersion: "macOS-26.1.0")
        _ = try await secondCache.symbols {
            Self.symbols(prefix: "current")
        }

        let fileNames = try FileManager.default.contentsOfDirectory(atPath: directory.path())
        XCTAssertEqual(fileNames.filter { $0 == "symbols.plist" }, ["symbols.plist"])
        XCTAssertTrue(FileManager.default.fileExists(atPath: unrelatedFileURL.path()))

        let loader = LoaderProbe()
        let reader = SFSymbolsCatalogCache(directory: directory, osVersion: "macOS-26.1.0")
        let cachedSymbols = try await reader.symbols {
            try await loader.load()
        }

        XCTAssertEqual(cachedSymbols.symbols, Self.symbols(prefix: "current").symbols)
        let callCount = await loader.numberOfCalls()
        XCTAssertEqual(callCount, 0)
    }
}

private extension SFSymbolsCatalogCacheTests {
    static func symbols(prefix: String) -> SFSymbols {
        let first = SFSymbol(
            name: "\(prefix).circle",
            searchTerms: [prefix, "circle"],
            categories: ["shapes"]
        )
        let second = SFSymbol(
            name: "\(prefix).square",
            searchTerms: [prefix, "square"],
            categories: ["shapes"]
        )
        return SFSymbols(
            symbols: [first, second],
            categories: [
                SFSymbolCategory(
                    key: "shapes",
                    icon: first,
                    symbols: [first, second]
                )
            ]
        )
    }

    func temporaryCacheDirectory() throws -> URL {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }
}

private actor LoaderProbe {
    private(set) var callCount = 0
    private let result: SFSymbols?
    private let delay: Duration?

    init(result: SFSymbols? = nil, delay: Duration? = nil) {
        self.result = result
        self.delay = delay
    }

    func load() async throws -> SFSymbols {
        callCount += 1
        if let delay {
            try await Task.sleep(for: delay)
        }
        guard let result else {
            throw Error.unexpectedCall
        }
        return result
    }

    func numberOfCalls() -> Int {
        callCount
    }

    enum Error: Swift.Error {
        case unexpectedCall
    }
}
