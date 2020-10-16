import Foundation

@objc public enum SuggestionType: Int {
    case user
    case site
}

@objc public extension SuggestionsTableView {

    convenience init(suggestionType: SuggestionType) {
        self.init()
    }

    func suggestions(for siteID: NSNumber, completion: @escaping ([UserSuggestion]?) -> Void) {
        guard let blog = SuggestionService.shared.persistedBlog(for: siteID) else { return }
        SuggestionService.shared.suggestions(for: blog, completion: completion)
    }

    func siteSuggestions(for siteID: NSNumber, completion: @escaping ([SiteSuggestion]?) -> Void) {
        let context = ContextManager.shared.mainContext
        guard let blog = BlogService(managedObjectContext: context).blog(byBlogId: siteID) else { return }

        XPostSuggestionService.getXPostSuggestions(for: blog) { result in
            switch result {
            case .success(let siteSuggestions):
                completion(siteSuggestions)
            case .failure(_):
                completion(nil)
            }
        }
    }

    func loadAvatar(for imageURL: URL?, success: @escaping (UIImage?) -> Void) {
        let imageSize = CGSize(width: SuggestionsTableViewCellAvatarSize, height: SuggestionsTableViewCellAvatarSize)
        if let image = cachedAvatar(for: imageURL, with: imageSize) {
            success(image)
        } else {
            fetchAvatar(for: imageURL, with: imageSize, success: success)
        }
    }

    private func cachedAvatar(for imageURL: URL?, with size: CGSize) -> UIImage? {
        var hash: NSString?
        let type = avatarSourceType(for: imageURL, with: &hash)

        if let hash = hash, let type = type {
            return WPAvatarSource.shared()?.cachedImage(forAvatarHash: hash as String, of: type, with: size)
        }
        return nil
    }

    private func fetchAvatar(for imageURL: URL?, with size: CGSize, success: @escaping ((UIImage?) -> Void)) {
        var hash: NSString?
        let type = avatarSourceType(for: imageURL, with: &hash)

        if let hash = hash, let type = type {
            WPAvatarSource.shared()?.fetchImage(forAvatarHash: hash as String, of: type, with: size, success: success)
        } else {
            success(nil)
        }
    }
}

extension SuggestionsTableView {
    func avatarSourceType(for imageURL: URL?, with hash: inout NSString?) -> WPAvatarSourceType? {
        if let imageURL = imageURL {
            return WPAvatarSource.shared()?.parseURL(imageURL, forAvatarHash: &hash)
        }
        return .unknown
    }
}
