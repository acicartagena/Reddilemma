// Copyright © 2020 ACartagena. All rights reserved.

import Foundation

public struct AuthenticationToken {
    public let token: AccessToken
    public let refreshToken: String

    init(response: AccessTokenResponse) {
        self.token = AccessToken(accessTokenResponse: response)
        self.refreshToken = response.refreshToken
    }
}
