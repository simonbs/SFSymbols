import Foundation

final class BundleCoreGlyphsDataProvider: CoreGlyphsDataProvider {
    enum ReadError: LocalizedError, CustomDebugStringConvertible {
        case plistNotFound(String)
        case failedReadingData(Error)

        var errorDescription: String? {
            debugDescription
        }

        var debugDescription: String {
            switch self {
            case .plistNotFound(let filename):
                "The property list '\(filename)' was not found in the bundle."
            case .failedReadingData(let error):
                "Failed reading plist data: \(error.localizedDescription)"
            }
        }
    }

    func data(forPlistNamed filename: String) async throws -> Data {
        let bundle = try await CoreGlyphsBundleLoader.load()
        guard let filePath = bundle.path(forResource: filename, ofType: "plist") else {
            throw ReadError.plistNotFound(filename)
        }
        do {
            return try Data(contentsOf: URL(filePath: filePath))
        } catch {
            throw ReadError.failedReadingData(error)
        }
    }
}
