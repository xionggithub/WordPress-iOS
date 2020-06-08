import XCTest
@testable import WordPress

class BlogDetailsSectionIndexTests: XCTestCase {
    func testFindingExistingSectionIndex() {
        let mySiteViewController = MySiteViewController()
        let sections = [
            BlogDetailsSection(title: nil, andRows: [], category: .general),
            BlogDetailsSection(title: nil, andRows: [], category: .domainCredit)
        ]
        let sectionIndex = mySiteViewController.findSectionIndex(sections: sections, category: .general)
        XCTAssertEqual(sectionIndex, 0)
    }

    func testFindingNonExistingSectionIndex() {
        let mySiteViewController = MySiteViewController()
        let sections = [
            BlogDetailsSection(title: nil, andRows: [], category: .general),
            BlogDetailsSection(title: nil, andRows: [], category: .domainCredit)
        ]
        let sectionIndex = mySiteViewController.findSectionIndex(sections: sections, category: .external)
        XCTAssertEqual(sectionIndex, NSNotFound)
    }

    func testFindingSectionIndexFromEmptySections() {
        let mySiteViewController = MySiteViewController()
        let sectionIndex = mySiteViewController.findSectionIndex(sections: [], category: .external)
        XCTAssertEqual(sectionIndex, NSNotFound)
    }
}
