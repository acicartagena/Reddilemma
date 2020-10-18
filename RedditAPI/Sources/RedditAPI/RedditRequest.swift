// Copyright © 2020 ACartagena. All rights reserved.

import Foundation

class RedditAPIURLRequest: URLRequest {
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
