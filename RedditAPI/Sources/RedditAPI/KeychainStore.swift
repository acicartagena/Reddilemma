// Copyright © 2020 ACartagena. All rights reserved.

import Foundation
import KeychainAccess

protocol KeychainStoring {
    var accessToken: AccessToken? { get set }
    var refreshToken: String? { get set }
}

class KeychainStore: KeychainStoring {
    static let shared = KeychainStore()
    private static let serviceName = "com.acicartagena.Reddilemma"
    private let keychain = Keychain(service: KeychainStore.serviceName)

    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    private init() { }

    var accessToken: AccessToken? {
        get {
            let data = keychain[data: "accessToken"]
            guard let accessTokenData = data,
                  let token = try? decoder.decode(AccessToken.self, from: accessTokenData)
            else {
                print("Error: can't decode \(String(describing: data)) for AccessToken")
                return nil
            }
            return token
        }
        set {
            guard let data = try? encoder.encode(newValue) else {
                print("Error: can't encode \(String(describing: newValue)) for AccessToken")
                return
            }
            keychain[data: "accessToken"] = data
        }
    }

    var refreshToken: String? {
        get { return keychain["refreshToken"] }
        set { keychain["refreshToken"] = newValue }
    }

}
