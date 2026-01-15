import Foundation

struct CategoriesPlist: Decodable {
    struct Category: Decodable, CustomDebugStringConvertible {
        let key: String
        let icon: String

        var debugDescription: String {
            key
        }
    }

    let categories: [Category]

    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        categories = try container.decode([Category].self)
    }
}

extension CategoriesPlist: CustomDebugStringConvertible {
    var debugDescription: String {
        let categoriesPrefix = categories.prefix(10).map(\.key).joined(separator: ", ")
        return "[CategoriesPlist \(categories.count) categories: \(categoriesPrefix), ...]"
    }
}
