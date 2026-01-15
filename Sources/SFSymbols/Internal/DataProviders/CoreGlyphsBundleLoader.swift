import Foundation

enum CoreGlyphsBundleLoader {
    enum LoadError: LocalizedError, CustomDebugStringConvertible {
        case failedDelayingAttempt
        case maxAttemptsExceeded

        var errorDescription: String? {
            debugDescription
        }

        var debugDescription: String {
            switch self {
            case .failedDelayingAttempt:
                "Failed delaying attempt"
            case .maxAttemptsExceeded:
                "Failed loading bundle after maximum attempts"
            }
        }
    }

    static func load() async throws(LoadError) -> Bundle {
        try await load(maxAttempts: 10)
    }
}

private extension CoreGlyphsBundleLoader {
    private static func load(maxAttempts: Int) async throws(LoadError) -> Bundle {
        for attempt in 1...maxAttempts {
            if let bundle = Bundle(identifier: "com.apple.CoreGlyphs") {
                return bundle
            }
            guard attempt < maxAttempts else {
                break
            }
            do {
                try await Task.sleep(nanoseconds: 500_000_000)
            } catch {
                throw LoadError.failedDelayingAttempt
            }
        }
        throw LoadError.maxAttemptsExceeded
    }
}
