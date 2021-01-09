// Copyright © 2020 ACartagena. All rights reserved.

import Foundation

public struct AccessToken: Codable {
    public let token: String
    public let expiresIn: Double

    init(accessTokenResponse: AccessTokenResponse) {
        self.token = accessTokenResponse.accessToken
        self.expiresIn = accessTokenResponse.expiresIn
    }

    init(refreshTokenResponse: RefreshTokenResponse) {
        self.token = refreshTokenResponse.accessToken
        self.expiresIn = refreshTokenResponse.expiresIn
    }

    init(token: String, expiresIn: Double) {
        self.token = token
        self.expiresIn = expiresIn
    }

    func isValid(now: Date = Date()) -> Bool {
        expiresIn > now.timeIntervalSince1970
    }
}
