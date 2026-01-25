import Foundation

protocol CoreGlyphsDataProvider: Sendable {
    func data(forPlistNamed filename: String) async throws -> Data
}

extension CoreGlyphsDataProvider where Self == CachingCoreGlyphsDataProvider {
    static func `default`() -> CoreGlyphsDataProvider {
        CachingCoreGlyphsDataProvider(
            wrapping: BundleCoreGlyphsDataProvider(),
            cacheDirectory: defaultCacheDirectory()
        )
    }

    private static func defaultCacheDirectory() -> URL {
        let applicationSupport = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!
        return applicationSupport
            .appendingPathComponent("SFSymbols", isDirectory: true)
            .appendingPathComponent("CoreGlyphs", isDirectory: true)
    }
}
