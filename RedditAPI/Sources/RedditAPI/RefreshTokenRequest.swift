// Copyright © 2020 ACartagena. All rights reserved.

import Foundation

class RedditRequest: URLRequest {
    let clientId = Secrets.clientId

    override init(url: URL) {
        super.init(url: url)
        commonInit()
    }
    func commonInit() {
        let processedClientId = "\(clientId):\("")".data(using: String.Encoding.utf8)?.base64EncodedString() ?? ""
        addValue("Basic \(processedClientId)", forHTTPHeaderField:"Authorization")
    }
}

struct RefreshTokenRequest {
    let urlRequest: URLRequest
    init(refreshToken: String, clientId: String = Secrets.clientId) {
        var requestBodyComponents = URLComponents()
        requestBodyComponents.queryItems = [URLQueryItem(name: "grant_type", value: "refresh_token"),
                                            URLQueryItem(name: "refresh_token", value: refreshToken)]

        let url = RedditAPIURLRequest(string: "https://www.reddit.com/api/v1/access_token/")!

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.httpBody = requestBodyComponents.query?.data(using: .utf8)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        urlRequest = request
    }
}
