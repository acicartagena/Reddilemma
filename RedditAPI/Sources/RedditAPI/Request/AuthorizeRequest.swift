// Copyright © 2020 ACartagena. All rights reserved.

import Foundation

public enum Scope: String, CaseIterable {
    case read
    case mySubreddits = "mysubreddits"
    case history
    case privateMessages = "privatemessages"
    case save
    case vote
}

private extension Array where Element == Scope {
    var scopeString: String {
        let result: String = reduce("") { (result, scope) in
            return result + scope.rawValue
        }
        return result
    }
}

struct AuthorizeRequest {
    private let defaultScope: [Scope] = [.read]
    let url: URL

    init(clientId: String = Secrets.clientId, state: String, redirectURI: String = Secrets.scheme, scope: [Scope] = Scope.allCases) {
        let allScopes = defaultScope + scope
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "www.reddit.com"
        urlComponents.path = "/api/v1/authorize.compact"
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "redirect_uri", value: redirectURI),

            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "duration", value: "permanent"),

            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "scope", value: allScopes.scopeString)
        ]
        url = urlComponents.url!
    }
}
