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

        let request = RedditAPIURLRequestBuilder(url: url, urlComponentsQuery: urlComponents).build()
        urlRequest = request
    }
}
