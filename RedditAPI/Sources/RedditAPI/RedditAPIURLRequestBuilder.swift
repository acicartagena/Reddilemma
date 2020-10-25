// Copyright © 2020 ACartagena. All rights reserved.

import Foundation

class RedditAPIURLRequestBuilder  {
    let clientId = Secrets.clientId

    enum HTTPHeader {
        case contentType(String)

        var headerField: String {
            switch self {
            case .contentType: return "Content-Type"
            }
        }

        var value: String {
            switch self {
            case .contentType(let value): return value
            }
        }
    }

    private var url: URL

    private let httpMethod = HTTPMethod.post
    private let httpBody: Data?
    private let httpHeaders: [HTTPHeader]

    init(url: URL, urlComponentsQuery: URLComponents) {
        self.url = url
        self.httpBody = urlComponentsQuery.query?.data(using: .utf8)
        httpHeaders = [.contentType("application/x-www-form-urlencoded")]
    }

    func build() -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.httpBody = httpBody
        for header in httpHeaders {
            request.addValue(header.value, forHTTPHeaderField: header.headerField)
        }
        let processedClientId = "\(clientId):\("")".data(using: String.Encoding.utf8)?.base64EncodedString() ?? ""
        request.addValue("Basic \(processedClientId)", forHTTPHeaderField:"Authorization")
        return request
    }
}
