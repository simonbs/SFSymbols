import Foundation

struct NameAvailabilityPlist: Decodable {
    struct Symbol: CustomDebugStringConvertible {
        let name: String
        let symbolsVersion: SymbolsVersion

        var debugDescription: String {
            name
        }
    }

    struct Symbols: Decodable {
        let arrayValue: [Symbol]

        init(from decoder: any Decoder) throws {
            let container = try decoder.singleValueContainer()
            let dict = try container.decode([String: SymbolsVersion].self)
            arrayValue = dict
                .map { Symbol(name: $0, symbolsVersion: $1) }
                .sorted { $0.name < $1.name }
        }
    }

    struct Release: CustomDebugStringConvertible {
        let symbolsVersion: SymbolsVersion
        let platforms: Platforms

        var debugDescription: String {
            "[Release \(symbolsVersion)]"
        }
    }

    struct Releases: Decodable {
        let arrayValue: [Release]

        init(from decoder: any Decoder) throws {
            let container = try decoder.singleValueContainer()
            let dict = try container.decode([String: Platforms].self)
            arrayValue = dict
                .compactMap { rawValue, platforms in
                    guard let symbolsVersion = SymbolsVersion(rawValue: rawValue) else {
                        return nil
                    }
                    return Release(symbolsVersion: symbolsVersion, platforms: platforms)
                }
                .sorted { $0.symbolsVersion < $1.symbolsVersion }
        }
    }

    struct Platforms: Decodable {
        let macOS: SemanticVersion
        let tvOS: SemanticVersion
        let watchOS: SemanticVersion
        let iOS: SemanticVersion
        let visionOS: SemanticVersion
        var current: SemanticVersion {
            #if os(macOS)
            return macOS
            #elseif os(tvOS)
            return tvOS
            #elseif os(watchOS)
            return watchOS
            #elseif os(iOS)
            return iOS
            #elseif os(visionOS)
            return visionOS
            #else
            #error("Platform not supported")
            #endif
        }
    }

    struct SymbolsVersion: Hashable, Decodable, CustomDebugStringConvertible, Comparable {
        let year: Int
        let release: Int?

        var debugDescription: String {
            if let release {
                "\(year).\(release)"
            } else {
                "\(year)"
            }
        }

        init(from decoder: any Decoder) throws {
            let container = try decoder.singleValueContainer()
            let stringValue = try container.decode(String.self)
            guard let decodedValue = Self(rawValue: stringValue) else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Unexpected calendar release '\(stringValue)'"
                )
            }
            self = decodedValue
        }

        init?(rawValue: String) {
            let components = rawValue.components(separatedBy: ".")
            if components.count == 1, let year = Int(components[0]) {
                self.year = year
                self.release = nil
            } else if components.count == 2, let year = Int(components[0]), let release = Int(components[1]) {
                self.year = year
                self.release = release
            } else {
                return nil
            }
        }

        static func < (lhs: Self, rhs: Self) -> Bool {
            if lhs.year != rhs.year {
                return lhs.year < rhs.year
            }
            let lhsRelease = lhs.release ?? 0
            let rhsRelease = rhs.release ?? 0
            return lhsRelease < rhsRelease
        }
    }

    struct SemanticVersion: Decodable, CustomDebugStringConvertible, Comparable {
        let major: Int
        let minor: Int?
        let patch: Int?

        var debugDescription: String {
            if let minor, let patch {
                "\(major).\(minor).\(patch)"
            } else if let minor {
                "\(major).\(minor)"
            } else {
                "\(major)"
            }
        }

        init(from decoder: any Decoder) throws {
            let container = try decoder.singleValueContainer()
            let stringValue = try container.decode(String.self)
            guard let decodedValue = Self(rawValue: stringValue) else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Unexpected semantic version '\(stringValue)'"
                )
            }
            self = decodedValue
        }

        init?(rawValue: String) {
            let components = rawValue.components(separatedBy: ".")
            if components.count == 1, let major = Int(components[0]) {
                self.major = major
                self.minor = nil
                self.patch = nil
            } else if components.count == 2, let major = Int(components[0]), let minor = Int(components[1]) {
                self.major = major
                self.minor = minor
                self.patch = nil
            } else if components.count == 3,
                      let major = Int(components[0]),
                      let minor = Int(components[1]),
                      let patch = Int(components[2]) {
                self.major = major
                self.minor = minor
                self.patch = patch
            } else {
                return nil
            }
        }

        static func < (lhs: Self, rhs: Self) -> Bool {
            if lhs.major != rhs.major {
                return lhs.major < rhs.major
            }
            let lhsMinor = lhs.minor ?? 0
            let rhsMinor = rhs.minor ?? 0
            if lhsMinor != rhsMinor {
                return lhsMinor < rhsMinor
            }
            let lhsPatch = lhs.patch ?? 0
            let rhsPatch = rhs.patch ?? 0
            return lhsPatch < rhsPatch
        }
    }

    enum CodingKeys: String, CodingKey {
        case symbols
        case yearToRelease = "year_to_release"
    }

    let symbols: Symbols
    let yearToRelease: Releases
    var availableSymbols: [Symbol] {
        let osVersion = ProcessInfo.processInfo.operatingSystemVersion
        let stringOSVersion = "\(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)"
        guard let osVersion = SemanticVersion(rawValue: stringOSVersion) else {
            return []
        }
        let availableSymbolVersions = Set(
            yearToRelease.arrayValue
                .filter { osVersion >= $0.platforms.current }
                .map(\.symbolsVersion)
        )
        return symbols.arrayValue.filter { availableSymbolVersions.contains($0.symbolsVersion) }
    }

    static func load(from bundle: Bundle) throws(CoreGlyphsPlistFileReader.ReadError) -> Self {
        try CoreGlyphsPlistFileReader.readFile(named: "name_availability", in: bundle, decoding: Self.self)
    }
}

extension NameAvailabilityPlist: CustomDebugStringConvertible {
    var debugDescription: String {
        let availableSymbols = self.availableSymbols
        let symbolsPrefix = availableSymbols.prefix(10).map(\.name).joined(separator: ", ")
        return "[NameAvailabilityPlist \(availableSymbols.count) symbols: \(symbolsPrefix), ...]"
    }
}
