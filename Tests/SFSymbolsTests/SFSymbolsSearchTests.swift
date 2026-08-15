@testable import SFSymbols
import XCTest

final class SFSymbolsSearchTests: XCTestCase {
    func testSearchPrioritizesExactAndSimpleAppVariants() {
        let symbols = [
            Self.symbol("airplane.up.forward.app"),
            Self.symbol("airplane.up.forward.app.fill"),
            Self.symbol("app.badge"),
            Self.symbol("app"),
            Self.symbol("app.fill"),
            Self.symbol("plus.app")
        ]

        let matches = symbols.search(matching: "app")

        XCTAssertEqual(matches.map(\.name), [
            "app",
            "app.fill",
            "app.badge",
            "plus.app",
            "airplane.up.forward.app",
            "airplane.up.forward.app.fill"
        ])
    }

    func testSearchPrioritizesHeartBeforeHeartVariantsAndRelatedSymbols() {
        let symbols = [
            Self.symbol("bolt.heart"),
            Self.symbol("heart.circle"),
            Self.symbol("heart"),
            Self.symbol("heart.fill"),
            Self.symbol("arrow.up.heart")
        ]

        let matches = symbols.search(matching: "heart")

        XCTAssertEqual(matches.map(\.name), [
            "heart",
            "heart.fill",
            "heart.circle",
            "bolt.heart",
            "arrow.up.heart"
        ])
    }

    func testSearchTermMatchesPreserveCatalogOrder() {
        let symbols = [
            Self.symbol("righttriangle", searchTerms: ["math"]),
            Self.symbol("percent", searchTerms: ["math"]),
            Self.symbol("multiply", searchTerms: ["math"])
        ]

        let matches = symbols.search(matching: "math")

        XCTAssertEqual(matches.map(\.name), ["righttriangle", "percent", "multiply"])
    }

    func testSearchAppliesLimitAfterRanking() {
        let symbols = [
            Self.symbol("airplane.up.forward.app"),
            Self.symbol("app"),
            Self.symbol("app.fill")
        ]

        let matches = symbols.search(matching: "app", limit: 2)

        XCTAssertEqual(matches.map(\.name), ["app", "app.fill"])
    }

    func testSearchReturnsAllMatchesWhenNoLimitIsPassed() {
        let symbols = [
            Self.symbol("airplane.up.forward.app"),
            Self.symbol("airplane.up.forward.app.fill"),
            Self.symbol("app.badge"),
            Self.symbol("app"),
            Self.symbol("app.fill"),
            Self.symbol("plus.app")
        ]

        let matches = symbols.search(matching: "app")

        XCTAssertEqual(matches.count, 6)
    }

    func testSearchIgnoresDotsAndSpecialCharactersInQueries() {
        let symbols = [
            Self.symbol("app"),
            Self.symbol("app.badge"),
            Self.symbol("app.fill")
        ]

        let spaceMatches = symbols.search(matching: "app fill")
        let dottedMatches = symbols.search(matching: "app.fill")
        let punctuationMatches = symbols.search(matching: "app-fill")

        XCTAssertEqual(spaceMatches.first?.name, "app.fill")
        XCTAssertEqual(dottedMatches.first?.name, "app.fill")
        XCTAssertEqual(punctuationMatches.first?.name, "app.fill")
    }

    func testSearchIgnoresDotsInSymbolNames() {
        let symbols = [
            Self.symbol("heart"),
            Self.symbol("heart.circle"),
            Self.symbol("heart.fill")
        ]

        let matches = symbols.search(matching: "heartcircle")

        XCTAssertEqual(matches.first?.name, "heart.circle")
    }

    func testSearchNormalizesSearchTerms() {
        let symbols = [
            Self.symbol("righttriangle", searchTerms: ["Math & Geometry"])
        ]

        let matches = symbols.search(matching: "mathgeometry")

        XCTAssertEqual(matches.first?.name, "righttriangle")
    }
}

private extension SFSymbolsSearchTests {
    static func symbol(_ name: String, searchTerms: [String] = [], categories: [String] = []) -> SFSymbol {
        SFSymbol(name: name, searchTerms: searchTerms, categories: categories)
    }
}
