import Foundation

@objcMembers @objc class Autocomplete: NSObject, Decodable {
    let title: String?
    let siteURL: URL?

    enum CodingKeys: String, CodingKey {
        case title
        case siteURL = "siteurl"
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        title = try values.decode(String.self, forKey: .title)
        siteURL = try values.decode(URL.self, forKey: .siteURL)
    }
}

@objcMembers @objc class XPost: NSObject, Decodable {


    let isSuccess: Bool?
    let autocompletes: [Autocomplete]?

    enum CodingKeys: String, CodingKey {
        case isSuccess = "success"
        case autocompletes = "data"
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        isSuccess = try values.decode(Bool.self, forKey: .isSuccess)
        let autocompletesString = try values.decode(String.self, forKey: .autocompletes)
        guard let autocompleteData = autocompletesString.data(using: .utf8) else {
            autocompletes = nil
            return
        }

        autocompletes = try JSONDecoder().decode([Autocomplete].self, from: autocompleteData)
    }
}


@objcMembers @objc class XPostSuggestionService: NSObject {

    static let shared = XPostSuggestionService()

    var autocompletes: [Autocomplete]?

    func authenticatedRequestSuggestions(for blog: Blog) -> [Autocomplete]? {

        if let results = autocompletes {
            return results
        }

        let authenticator = RequestAuthenticator(blog: blog)
        guard let url = URL(string: "https://p8yp2.wordpress.com/?get-xpost-data") else {
            return nil
        }
        authenticator?.request(url: url, cookieJar: HTTPCookieStorage.shared) { _ in

            var authenticatedRequest = URLRequest(url: url)

            guard let cookies = HTTPCookieStorage.shared.cookies else { return }
            authenticatedRequest.allHTTPHeaderFields = HTTPCookie.requestHeaderFields(with: cookies)

            URLSession.shared.dataTask(with: authenticatedRequest) { data, response, error in
                guard let data = data else {
                    return
                }

                guard let autocompletes = try? JSONDecoder().decode(XPost.self, from: data).autocompletes else {
                    return
                }

                print("autocompletes: ", autocompletes)

                self.autocompletes = autocompletes
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .SuggestionListUpdated, object: blog.dotComID)
                }
            }.resume()
        }

        return nil
    }
}
