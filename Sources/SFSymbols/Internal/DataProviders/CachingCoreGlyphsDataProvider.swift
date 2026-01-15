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

    private let logger = Logger(subsystem: "SFSymbols", category: "CachingCoreGlyphsDataProvider")
    private let dataProvider: CoreGlyphsDataProvider
    private let cacheDirectory: URL

    init(wrapping dataProvider: CoreGlyphsDataProvider, cacheDirectory: URL) {
        self.dataProvider = dataProvider
        self.cacheDirectory = cacheDirectory
    }

    func data(forPlistNamed filename: String) async throws -> Data {
        do {
            let data = try await dataProvider.data(forPlistNamed: filename)
            await cacheLocally(data, filename: filename)
            return data
        } catch {
            return try loadFromCache(filename: filename, underlyingError: error)
        }
    }
}

private extension CachingCoreGlyphsDataProvider {
    private func cacheLocally(_ data: Data, filename: String) async {
        let fileURL = cacheFileURL(for: filename)
        do {
            try FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            // Caching failures are non-fatal. We still have the data from the bundle.
        }
    }

    private func loadFromCache(filename: String, underlyingError: Error) throws -> Data {
        do {
            let fileURL = cacheFileURL(for: filename)
            return try Data(contentsOf: fileURL)
        } catch {
            logger.error(
                """
                Failed reading '\(filename)'. \
                Bundle error: \(underlyingError.localizedDescription). \
                Cache error: \(error.localizedDescription)
                """
            )
            throw ReadError.cacheUnavailable(underlyingError: underlyingError)
        }
    }

    private func cacheFileURL(for filename: String) -> URL {
        cacheDirectory.appendingPathComponent("\(filename).plist")
    }
}
