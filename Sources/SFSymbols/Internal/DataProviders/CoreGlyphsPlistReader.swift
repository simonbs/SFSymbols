import Foundation

struct CoreGlyphsPlistReader: Sendable {
    enum ReadError: LocalizedError, CustomDebugStringConvertible {
        case decodingError(DecodingError)
        case unknownError(Error)

        var errorDescription: String? {
            debugDescription
        }

        var debugDescription: String {
            switch self {
            case .decodingError(let error):
                error.localizedDescription
            case .unknownError(let error):
                error.localizedDescription
            }
        }
    }

    let dataProvider: CoreGlyphsDataProvider

    init(dataProvider: CoreGlyphsDataProvider = .default()) {
        self.dataProvider = dataProvider
    }

    func read<T: Decodable>(plistNamed filename: String, as type: T.Type) async throws -> T {
        let data = try await dataProvider.data(forPlistNamed: filename)
        do {
            let decoder = PropertyListDecoder()
            return try decoder.decode(type, from: data)
        } catch let error as DecodingError {
            throw ReadError.decodingError(error)
        } catch {
            throw ReadError.unknownError(error)
        }
    }
}
