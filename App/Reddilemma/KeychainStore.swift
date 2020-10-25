// Copyright © 2020 ACartagena. All rights reserved.

import Foundation
import RedditAPI
import KeychainAccess

protocol KeychainStoring {
    var accessToken: String? { get set }
    var refreshToken: String? { get set }
//    func save(tokens: AuthenticationToken)
}

class KeychainStore: KeychainStoring {
    private static let serviceName = "com.acicartagena.Reddilemma"
    private let keychain = Keychain(service: KeychainStore.serviceName)

    var accessToken: String? {
        get { return keychain["accessToken"] }
        set { keychain["accessToken"] = newValue }
    }

    var refreshToken: String? {
        get { return keychain["refreshToken"] }
        set { keychain["refreshToken"] = newValue }
    }

//    func save(tokens: AuthenticationToken) {
//        self.accessToken = tokens.accessToken
//        self.refreshToken = tokens.refreshToken
//        print("\(keychain)")
//        let items = keychain.allItems()
//        for item in items {
//          print("item: \(item)")
//        }
//    }
}
