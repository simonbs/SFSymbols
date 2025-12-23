import Foundation

enum CoreGlyphsPlistFileReader {
    enum ReadError: LocalizedError, CustomDebugStringConvertible {
        case propertyListNotFound
        case failedReadingFile
        case decodingError(DecodingError)
        case unknownError(Error)

        var errorDescription: String? {
            debugDescription
        }

        var debugDescription: String {
            switch self {
            case .propertyListNotFound:
                "The property list was not found in the bundle."
            case .failedReadingFile:
                "Could not read data from the property list."
            case .decodingError(let error):
                error.localizedDescription
            case .unknownError(let error):
                error.localizedDescription
            }
        }
    }

    static func readFile<T: Decodable>(
        named filename: String,
        in bundle: Bundle,
        decoding valueType: T.Type
    ) throws(ReadError) -> T {
        guard let filePath = bundle.path(forResource: filename, ofType: "plist") else {
            throw .propertyListNotFound
        }
        guard let data = try? Data(contentsOf: URL(filePath: filePath)) else {
            throw .failedReadingFile
        }
        do {
            let decoder = PropertyListDecoder()
            return try decoder.decode(valueType.self, from: data)
        } catch let error as DecodingError {
            throw .decodingError(error)
        } catch {
            throw .unknownError(error)
        }
    }
}
