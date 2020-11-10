import Foundation

/// This is a convenience protocol to make the migration from `BlogDetailHeaderView` to `NewBlogDetailHeaderView` easier.
/// We should remove this protocol once the migration is complete.
///
@objc
protocol BlogDetailHeader: NSObjectProtocol {

    @objc
    var blog: Blog? { get set }

    @objc
    weak var delegate: BlogDetailHeaderViewDelegate? { get set }

    @objc
    var updatingIcon: Bool { get set }

    @objc
    var blavatarImageView: UIImageView { get }
}
