import Foundation

struct XPostSuggestionService {

    static var hasRequested = false

    static func getXPostSuggestions(for blog: Blog, completion: @escaping (Result<[SiteSuggestion], Error>) -> Void) {

        guard !hasRequested else {
            return
        }
        self.hasRequested = true

        guard let api = blog.wordPressComRestApi() else {
            let error = NSError(domain: "XPostSuggestionService", code: 0, userInfo: [NSDebugDescriptionErrorKey: "API not found"])
            completion(.failure(error))
            return
        }

        guard let managedObjectContext = blog.managedObjectContext else {
            let error = NSError(domain: "XPostSuggestionService", code: 0, userInfo: [NSDebugDescriptionErrorKey: "Managed object context not available"])
            completion(.failure(error))
            return
        }

        guard let hostname = blog.hostname else {
            let error = NSError(domain: "XPostSuggestionService", code: 0, userInfo: [NSDebugDescriptionErrorKey: "Blog hostname not available"])
            completion(.failure(error))
            return
        }


        let urlString = "/wpcom/v2/sites/\(hostname)/xposts"

        api.GET(urlString, parameters: nil) { responseObject, httpResponse in
            guard let data = try? JSONSerialization.data(withJSONObject: responseObject) else {
                return
            }

            self.purgeSiteSuggestions(for: blog, using: managedObjectContext)

            if let siteSuggestions = self.persistSiteSuggestions(from: data, to: blog, using: managedObjectContext) {
                completion(.success(siteSuggestions))
            } else {
                let error = NSError(domain: "XPostSuggestionService", code: 0, userInfo: [NSDebugDescriptionErrorKey: "Error parsing or persisting site suggestions"])
                completion(.failure(error))
            }
            self.hasRequested = false
        } failure: { error, httpResponse in
            completion(.failure(error))
            self.hasRequested = false
        }
    }

    private static func purgeSiteSuggestions(for blog: Blog, using managedObjectContext: NSManagedObjectContext) {
        blog.siteSuggestions?.forEach { siteSuggestion in
            managedObjectContext.delete(siteSuggestion)
        }
    }

    private static func persistSiteSuggestions(from data: Data, to blog: Blog, using managedObjectContext: NSManagedObjectContext) -> [SiteSuggestion]? {

        let decoder = JSONDecoder()
        decoder.userInfo[CodingUserInfoKey.managedObjectContext] = managedObjectContext
        if let siteSuggestions = try? decoder.decode([SiteSuggestion].self, from: data) {
            blog.siteSuggestions = Set(siteSuggestions)
            try? blog.managedObjectContext?.save()
            return siteSuggestions
        }
        return nil
    }
}
