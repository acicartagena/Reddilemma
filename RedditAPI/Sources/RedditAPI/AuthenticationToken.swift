// Copyright © 2020 ACartagena. All rights reserved.

import Foundation

public struct AuthenticationToken {
    public let accessToken: String
    public let refreshToken: String

    init(response: AccessTokenResponse) {
        self.accessToken = response.accessToken
        self.refreshToken = response.refreshToken
    }
}
