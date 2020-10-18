// Copyright © 2020 ACartagena. All rights reserved.

import Foundation

struct AccessTokenRequest {
    let urlRequest: URLRequest

    init(code: String, scheme: String = Secrets.scheme) {
        var urlComponents = URLComponents()
        urlComponents.queryItems = [URLQueryItem(name: "grant_type", value: "authorization_code"),
                                    URLQueryItem(name: "code", value: code),
                                    URLQueryItem(name: "redirect_uri", value: scheme)]

        let url = URL(string: "https://www.reddit.com/api/v1/access_token/")!

        var request = RedditAPIURLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.httpBody = urlComponents.query?.data(using: .utf8)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        urlRequest = request
    }
}
