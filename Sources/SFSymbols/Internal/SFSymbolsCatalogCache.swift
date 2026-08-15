import Foundation
import OSLog

actor SFSymbolsCatalogCache {
    typealias Loader = @Sendable () async throws -> SFSymbols

    static let shared = SFSymbolsCatalogCache()

    private static let formatVersion = 1
    private let logger = Logger(subsystem: "SFSymbols", category: "SFSymbolsCatalogCache")
    private let directory: URL
    private let osVersion: String
    private var memoryValue: SFSymbols?
    private var loadingTask: Task<SFSymbols, any Error>?
    private var directoryCreated = false

    init(
        directory: URL = SFSymbolsCatalogCache.defaultCacheDirectory(),
        osVersion: String = SFSymbolsCatalogCache.currentOperatingSystemVersion()
    ) {
        self.directory = directory
        self.osVersion = osVersion
    }

    func symbols(loadUsing loader: @escaping Loader) async throws -> SFSymbols {
        if let memoryValue {
            return memoryValue
        }
        if let diskValue = readFromDisk() {
            memoryValue = diskValue
            return diskValue
        }
        if let loadingTask {
            return try await loadingTask.value
        }
        let loadingTask = Task {
            try await loader()
        }
        self.loadingTask = loadingTask
        do {
            let loadedValue = try await loadingTask.value
            memoryValue = loadedValue
            writeToDisk(loadedValue)
            self.loadingTask = nil
            return loadedValue
        } catch {
            self.loadingTask = nil
            throw error
        }
    }

    private func readFromDisk() -> SFSymbols? {
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = PropertyListDecoder()
            let cacheFile = try decoder.decode(CacheFile.self, from: data)
            guard cacheFile.formatVersion == Self.formatVersion else {
                return nil
            }
            guard cacheFile.osVersion == osVersion else {
                return nil
            }
            return cacheFile.symbolsCatalog
        } catch {
            logger.debug("Could not read symbols catalog cache: \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }

    private func writeToDisk(_ symbols: SFSymbols) {
        do {
            try createDirectoryIfNeeded()
            let cacheFile = CacheFile(
                formatVersion: Self.formatVersion,
                osVersion: osVersion,
                symbolsCatalog: symbols
            )
            let encoder = PropertyListEncoder()
            encoder.outputFormat = .binary
            let data = try encoder.encode(cacheFile)
            try data.write(to: fileURL, options: .atomic)
            #if canImport(UIKit)
            try FileManager.default.setAttributes(
                [.protectionKey: FileProtectionType.none],
                ofItemAtPath: fileURL.path()
            )
            #endif
            removeStaleCacheFiles()
        } catch {
            logger.debug("Could not write symbols catalog cache: \(error.localizedDescription, privacy: .public)")
        }
    }

    private func removeStaleCacheFiles() {
        do {
            let cacheFileURLs = try FileManager.default.contentsOfDirectory(
                at: directory,
                includingPropertiesForKeys: nil
            )
            let currentFileName = fileURL.lastPathComponent
            for cacheFileURL in cacheFileURLs {
                guard cacheFileURL.lastPathComponent != currentFileName else {
                    continue
                }
                guard cacheFileURL.lastPathComponent.hasPrefix("symbols-") else {
                    continue
                }
                guard cacheFileURL.pathExtension == "plist" else {
                    continue
                }
                try FileManager.default.removeItem(at: cacheFileURL)
            }
        } catch {
            logger.debug(
                "Could not remove stale symbols catalog caches: \(error.localizedDescription, privacy: .public)"
            )
        }
    }

    private func createDirectoryIfNeeded() throws {
        guard !directoryCreated else {
            return
        }
        #if canImport(UIKit)
        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true,
            attributes: [.protectionKey: FileProtectionType.none]
        )
        #else
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        #endif
        directoryCreated = true
    }

    private var fileURL: URL {
        directory.appendingPathComponent("symbols-\(sanitizedOSVersion)-v\(Self.formatVersion).plist")
    }

    private var sanitizedOSVersion: String {
        String(osVersion.map { character in
            if character.isLetter || character.isNumber || character == "." ||
                character == "-" || character == "_" {
                return character
            } else {
                return "-"
            }
        })
    }

    private static func defaultCacheDirectory() -> URL {
        let applicationSupport = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!
        return applicationSupport
            .appendingPathComponent("SFSymbols", isDirectory: true)
            .appendingPathComponent("Catalog", isDirectory: true)
    }

    private static func currentOperatingSystemVersion() -> String {
        let osVersion = ProcessInfo.processInfo.operatingSystemVersion
        #if os(macOS)
        let platform = "macOS"
        #elseif os(tvOS)
        let platform = "tvOS"
        #elseif os(watchOS)
        let platform = "watchOS"
        #elseif os(iOS)
        let platform = "iOS"
        #elseif os(visionOS)
        let platform = "visionOS"
        #else
        let platform = "unknown"
        #endif
        return "\(platform)-\(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)"
    }
}

private extension SFSymbolsCatalogCache {
    struct CacheFile: Codable {
        let formatVersion: Int
        let osVersion: String
        let symbols: [CachedSymbol]
        let categories: [CachedCategory]

        init(formatVersion: Int, osVersion: String, symbolsCatalog: SFSymbols) {
            self.formatVersion = formatVersion
            self.osVersion = osVersion
            self.symbols = symbolsCatalog.symbols.map(CachedSymbol.init)

            var symbolIndexesByName: [String: Int] = [:]
            symbolIndexesByName.reserveCapacity(symbolsCatalog.symbols.count)
            for (index, symbol) in symbolsCatalog.symbols.enumerated() {
                symbolIndexesByName[symbol.name] = index
            }

            self.categories = symbolsCatalog.categories.compactMap { category in
                guard let iconIndex = symbolIndexesByName[category.icon.name] else {
                    return nil
                }
                let symbolIndexes = category.symbols.compactMap { symbolIndexesByName[$0.name] }
                guard symbolIndexes.count == category.symbols.count else {
                    return nil
                }
                return CachedCategory(
                    key: category.key,
                    iconIndex: iconIndex,
                    symbolIndexes: symbolIndexes
                )
            }
        }

        var symbolsCatalog: SFSymbols? {
            let decodedSymbols = symbols.map(\.symbol)
            let decodedCategories = categories.compactMap { category -> SFSymbolCategory? in
                guard decodedSymbols.indices.contains(category.iconIndex) else {
                    return nil
                }
                guard category.symbolIndexes.allSatisfy({ decodedSymbols.indices.contains($0) }) else {
                    return nil
                }
                return SFSymbolCategory(
                    key: category.key,
                    icon: decodedSymbols[category.iconIndex],
                    symbols: category.symbolIndexes.map { decodedSymbols[$0] }
                )
            }
            guard decodedCategories.count == categories.count else {
                return nil
            }
            return SFSymbols(symbols: decodedSymbols, categories: decodedCategories)
        }
    }

    struct CachedSymbol: Codable {
        let name: String
        let searchTerms: [String]
        let categories: [String]

        init(symbol: SFSymbol) {
            self.name = symbol.name
            self.searchTerms = symbol.searchTerms
            self.categories = symbol.categories
        }

        var symbol: SFSymbol {
            SFSymbol(name: name, searchTerms: searchTerms, categories: categories)
        }
    }

    struct CachedCategory: Codable {
        let key: String
        let iconIndex: Int
        let symbolIndexes: [Int]
    }
}
