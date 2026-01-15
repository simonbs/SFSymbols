import Foundation
import OSLog

final class CachingCoreGlyphsDataProvider: CoreGlyphsDataProvider {
    enum ReadError: LocalizedError, CustomDebugStringConvertible {
        case cacheUnavailable(underlyingError: Error)

        var errorDescription: String? {
            debugDescription
        }

        var debugDescription: String {
            switch self {
            case .cacheUnavailable(let underlyingError):
                """
                Failed loading from bundle and cache is unavailable. \
                Original error: \(underlyingError.localizedDescription)
                """
            }
        }
    }

    private let dataProvider: CoreGlyphsDataProvider
    private let cacheStorage: CacheStorage

    init(wrapping dataProvider: CoreGlyphsDataProvider, cacheDirectory: URL) {
        self.dataProvider = dataProvider
        self.cacheStorage = CacheStorage(directory: cacheDirectory)
    }

    func data(forPlistNamed filename: String) async throws -> Data {
        do {
            let data = try await dataProvider.data(forPlistNamed: filename)
            Task { await cacheStorage.write(data, filename: filename) }
            return data
        } catch {
            return try await cacheStorage.read(filename: filename, underlyingError: error)
        }
    }
}

private actor CacheStorage {
    private let logger = Logger(subsystem: "SFSymbols", category: "CacheStorage")
    private let directory: URL
    private var directoryCreated = false

    init(directory: URL) {
        self.directory = directory
    }

    func write(_ data: Data, filename: String) {
        do {
            try createDirectoryIfNeeded()
            let url = fileURL(for: filename)
            try data.write(to: url, options: .atomic)
            #if os(iOS)
            try FileManager.default.setAttributes(
                [.protectionKey: FileProtectionType.none],
                ofItemAtPath: url.path()
            )
            #endif
        } catch {
            // Caching failures are non-fatal. We still have the data from the bundle.
        }
    }

    func read(filename: String, underlyingError: Error) throws -> Data {
        do {
            return try Data(contentsOf: fileURL(for: filename))
        } catch {
            logger.error(
                """
                Failed reading '\(filename)'. \
                Bundle error: \(underlyingError.localizedDescription). \
                Cache error: \(error.localizedDescription)
                """
            )
            throw CachingCoreGlyphsDataProvider.ReadError.cacheUnavailable(underlyingError: underlyingError)
        }
    }

    private func createDirectoryIfNeeded() throws {
        guard !directoryCreated else {
            return
        }
        #if os(iOS)
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

    private func fileURL(for filename: String) -> URL {
        directory.appendingPathComponent("\(filename).plist")
    }
}
