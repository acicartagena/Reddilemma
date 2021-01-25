// Copyright © 2020 ACartagena. All rights reserved.

import Foundation

public struct AccessTokenResponse: Decodable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Double
    let scope: String
    let refreshToken: String
}
