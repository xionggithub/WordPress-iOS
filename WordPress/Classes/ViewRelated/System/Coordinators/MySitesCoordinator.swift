import UIKit

@objc
class MySitesCoordinator: NSObject {
    let mySiteSplitViewController: WPSplitViewController
    let mySiteNavigationController: UINavigationController

    @objc
    init(mySiteSplitViewController: WPSplitViewController,
         mySiteNavigationController: UINavigationController) {
        self.mySiteSplitViewController = mySiteSplitViewController
        self.mySiteNavigationController = mySiteNavigationController

        super.init()
    }

    private func prepareToNavigate() {
        WPTabBarController.sharedInstance().showMySiteTab()

        if let firstController = mySiteNavigationController.viewControllers.first {
            mySiteNavigationController.viewControllers = [firstController]
        }
    }

    func showMySites() {
        prepareToNavigate()
    }

    @objc(showDetailsForBlog:)
    func showBlogDetails(for blog: Blog) {
        showBlogDetails(for: blog, then: nil)
    }

    func showBlogDetails(for blog: Blog, then subsection: BlogDetailsSubsection? = nil) {
        prepareToNavigate()

        if FeatureFlag.mySiteHierarchy.enabled {
            guard let mySiteViewController = mySiteNavigationController.viewControllers.first as? MySiteViewController else {
                return
            }

            mySiteViewController.blog = blog

            if let subsection = subsection {
                mySiteViewController.showDetailView(for: subsection)
            }
        } else {
            guard let blogListViewController = mySiteNavigationController.viewControllers.first as? BlogListViewController else {
                return
            }

            blogListViewController.setSelectedBlog(blog, animated: false)

            if let subsection = subsection,
                let mySiteViewController = mySiteNavigationController.topViewController as? MySiteViewController {
                mySiteViewController.showDetailView(for: subsection)
            }
        }
    }

    // MARK: - Stats

    func showStats(for blog: Blog) {
        showBlogDetails(for: blog, then: .stats)
    }

    func showStats(for blog: Blog, timePeriod: StatsPeriodType) {
        showBlogDetails(for: blog)

        if let mySiteViewController = mySiteNavigationController.topViewController as? MySiteViewController {
            // Setting this user default is a bit of a hack, but it's by far the easiest way to
            // get the stats view controller displaying the correct period. I spent some time
            // trying to do it differently, but the existing stats view controller setup is
            // quite complex and contains many nested child view controllers. As we're planning
            // to revamp that section in the not too distant future, I opted for this simpler
            // configuration for now. 2018-07-11 @frosty
            UserDefaults.standard.set(timePeriod.rawValue, forKey: MySitesCoordinator.statsPeriodTypeDefaultsKey)

            mySiteViewController.showDetailView(for: .stats)
        }
    }

    func showActivityLog(for blog: Blog) {
        showBlogDetails(for: blog, then: .activity)
    }

    private static let statsPeriodTypeDefaultsKey = "LastSelectedStatsPeriodType"

    // MARK: - My Sites

    func showPages(for blog: Blog) {
        showBlogDetails(for: blog, then: .pages)
    }

    func showPosts(for blog: Blog) {
        showBlogDetails(for: blog, then: .posts)
    }

    func showMedia(for blog: Blog) {
        showBlogDetails(for: blog, then: .media)
    }

    func showComments(for blog: Blog) {
        showBlogDetails(for: blog, then: .comments)
    }

    func showSharing(for blog: Blog) {
        showBlogDetails(for: blog, then: .sharing)
    }

    func showPeople(for blog: Blog) {
        showBlogDetails(for: blog, then: .people)
    }

    func showPlugins(for blog: Blog) {
        showBlogDetails(for: blog, then: .plugins)
    }

    func showManagePlugins(for blog: Blog) {
        guard blog.supports(.pluginManagement) else {
            return
        }

        // PerformWithoutAnimation is required here, otherwise the view controllers
        // potentially get added to the navigation controller out of order
        // (ShowDetailViewController, used by MySiteViewController is animated)
        UIView.performWithoutAnimation {
            showBlogDetails(for: blog, then: .plugins)
        }

        guard let site = JetpackSiteRef(blog: blog),
            let navigationController = mySiteSplitViewController.topDetailViewController?.navigationController else {
            return
        }

        let query = PluginQuery.all(site: site)
        let listViewController = PluginListViewController(site: site, query: query)

        navigationController.pushViewController(listViewController, animated: false)
    }
}
