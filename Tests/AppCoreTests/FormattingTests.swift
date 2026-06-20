import AppCore
import XCTest

final class FormattingTests: XCTestCase {
    func testCompactCountUsesRussianSuffixes() {
        XCTAssertEqual(UnioFormatters.compactCount(999), "999")
        XCTAssertEqual(UnioFormatters.compactCount(1_200), "1.2 тыс.")
        XCTAssertEqual(UnioFormatters.compactCount(1_500_000), "1.5 млн")
    }

    func testRelativeTime() {
        let now = Date(timeIntervalSince1970: 10_000)
        XCTAssertEqual(UnioFormatters.relativeTime(Date(timeIntervalSince1970: 9_970), now: now), "только что")
        XCTAssertEqual(UnioFormatters.relativeTime(Date(timeIntervalSince1970: 9_400), now: now), "10 мин")
        XCTAssertEqual(UnioFormatters.relativeTime(Date(timeIntervalSince1970: 6_400), now: now), "1 ч")
    }
}
