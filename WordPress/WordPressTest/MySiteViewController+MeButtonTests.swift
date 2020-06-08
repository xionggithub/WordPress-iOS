@testable import WordPress
import XCTest

class MockScenePresenter: ScenePresenter {
    var presentedViewController: UIViewController?
    var presentExpectation: XCTestExpectation?

    func present(on viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard viewController is MySiteViewController else {
            XCTFail("Invalid presenting viewController")
            return
        }
        presentedViewController = UIViewController()
        presentedViewController?.accessibilityLabel = "testController"
        presentExpectation?.fulfill()
    }
}

class MySiteViewControllerTests: XCTestCase {

    private var mySiteViewController: MySiteViewController?
    private var scenePresenter: MockScenePresenter?

    private struct TestConstants {
        static let meButtonLabel = NSLocalizedString("Me", comment: "Accessibility label for the Me button in My Site.")
        static let meButtonHint = NSLocalizedString("Open the Me Section", comment: "Accessibility hint the Me button in My Site.")
    }


    override func setUp() {
        scenePresenter = MockScenePresenter()
        guard let presenter = scenePresenter else {
            XCTFail("Presenter not initialized")
            return
        }
        mySiteViewController = MySiteViewController(meScenePresenter: presenter)
    }

    override func tearDown() {
        mySiteViewController = nil
        scenePresenter = nil
    }

    func testInitWithScenePresenter() {
        // Given
        guard let controller = mySiteViewController else {
            XCTFail("My site viewController not initialized")
            return
        }
        // When
        controller.addMeButtonToNavigationBar()
        // Then
        guard let meButton = controller.navigationItem.rightBarButtonItem else {
            XCTFail("Me Button not installed")
            return
        }

        XCTAssertEqual(meButton.accessibilityLabel, TestConstants.meButtonLabel)
        XCTAssertEqual(meButton.accessibilityHint, TestConstants.meButtonHint)
    }

    func testPresentMeOnButtonTap() {
        // Given
        guard let controller = mySiteViewController else {
            XCTFail("My site viewController not initialized")
            return
        }
        controller.addMeButtonToNavigationBar()
        guard controller.navigationItem.rightBarButtonItem != nil else {
            XCTFail("Me Button not installed")
            return
        }
        scenePresenter?.presentExpectation = expectation(description: "Me was presented")
        // When
        
        guard let target = mySiteViewController?.target(forAction: #selector(MySiteViewController.presentHandler),
                                                        withSender: mySiteViewController) else {
                                                            XCTFail("Target not found")
                                                            return
        }

        let actionableTarget = target as AnyObject
        _ = actionableTarget.perform(#selector(MySiteViewController.presentHandler))

        // Then
        guard let presentedController = scenePresenter?.presentedViewController else {
            XCTFail("Presented controller was not instantiated")
            return
        }
        XCTAssertEqual(presentedController.accessibilityLabel, "testController")
        waitForExpectations(timeout: 4) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
}
