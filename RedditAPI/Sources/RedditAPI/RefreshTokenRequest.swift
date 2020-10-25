// Copyright © 2020 ACartagena. All rights reserved.

import Foundation

struct RefreshTokenRequest {
    let urlRequest: URLRequest
    init(refreshToken: String, clientId: String = Secrets.clientId) {
        var requestBodyComponents = URLComponents()
        requestBodyComponents.queryItems = [URLQueryItem(name: "grant_type", value: "refresh_token"),
                                            URLQueryItem(name: "refresh_token", value: refreshToken)]

        let url = URL(string: "https://www.reddit.com/api/v1/access_token/")!
        var request = RedditAPIURLRequestBuilder(url: url, urlComponentsQuery: requestBodyComponents).build()
        urlRequest = request
    }
}
