import XCTest
@testable import WordPress

class MySiteSubsectionToSectionCategoryTests: XCTestCase {
    func testEachSubsectionToSectionCategory() {
        let mySiteViewController = MySiteViewController()
        XCTAssertEqual(mySiteViewController.sectionCategory(subsection: .domainCredit), .domainCredit)
        XCTAssertEqual(mySiteViewController.sectionCategory(subsection: .quickStart), .quickStart)
        XCTAssertEqual(mySiteViewController.sectionCategory(subsection: .stats), .general)
        XCTAssertEqual(mySiteViewController.sectionCategory(subsection: .activity), .general)
        XCTAssertEqual(mySiteViewController.sectionCategory(subsection: .pages), .publish)
        XCTAssertEqual(mySiteViewController.sectionCategory(subsection: .posts), .publish)
        XCTAssertEqual(mySiteViewController.sectionCategory(subsection: .media), .publish)
        XCTAssertEqual(mySiteViewController.sectionCategory(subsection: .comments), .publish)
        XCTAssertEqual(mySiteViewController.sectionCategory(subsection: .themes), .personalize)
        XCTAssertEqual(mySiteViewController.sectionCategory(subsection: .customize), .personalize)
        XCTAssertEqual(mySiteViewController.sectionCategory(subsection: .sharing), .configure)
        XCTAssertEqual(mySiteViewController.sectionCategory(subsection: .people), .configure)
        XCTAssertEqual(mySiteViewController.sectionCategory(subsection: .plugins), .configure)
    }
}
