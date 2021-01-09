// Copyright © 2020 ACartagena. All rights reserved.

import Foundation
import Combine

enum RedditAPIError: Error {
    case noRefreshToken
    case loginRequired
}

protocol TokenActions {
    func token(forceRefresh: Bool) -> AnyPublisher<AccessToken, Error>?
}

class TokenService: TokenActions {
    private let networking: NetworkingActions
    private var keychainStore: KeychainStoring
    private var currentToken: AccessToken? {
        didSet {
            keychainStore.accessToken = currentToken
        }
    }
    private let queue = DispatchQueue(label: "TokenService.\(UUID().uuidString)")

    private var refreshPublisher: AnyPublisher<AccessToken, Error>?

    init(keychainStore: KeychainStoring = KeychainStore.shared, networking: NetworkingActions = Networking.shared) {
        self.keychainStore = keychainStore
        self.currentToken = keychainStore.accessToken
        self.networking = networking
    }

    private func refresh() -> AnyPublisher<RefreshTokenResponse, Error> {
        guard let refreshToken = keychainStore.refreshToken else {
            return Fail(error: RedditAPIError.noRefreshToken).eraseToAnyPublisher()
                //Fail(outputType: RefreshTokenResponse.self, failure: RedditAPIError.noRefreshToken as Error)
                //.eraseToAnyPublisher()
        }
        return refresh(using: refreshToken)
    }

    private func refresh(using refreshToken: String) -> AnyPublisher<RefreshTokenResponse, Error> {
        let urlRequest = RefreshTokenRequest(refreshToken: refreshToken).urlRequest
        return (networking.httpRequest(for: urlRequest) as AnyPublisher<RefreshTokenResponse, Error>)
            .eraseToAnyPublisher()
    }

    // https://www.donnywals.com/building-a-concurrency-proof-token-refresh-flow-in-combine/

    func token(forceRefresh: Bool = false) -> AnyPublisher<AccessToken, Error>? {
        return queue.sync { [weak self] in
            //already fetching a new token
            if let publisher = self?.refreshPublisher {
                return publisher
            }

            guard let token = self?.currentToken else {
                return Fail(error: RedditAPIError.loginRequired)
                        .eraseToAnyPublisher()
            }

            if token.isValid(), !forceRefresh {
                return Just(token)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }

            let publisher = refresh()
                .map { AccessToken(refreshTokenResponse: $0) }
                .share()
                .handleEvents(receiveOutput: { (token) in
                    self?.currentToken = token
                }, receiveCompletion: { _ in
                    self?.queue.sync {
                        self?.refreshPublisher = nil
                    }
                })
                .eraseToAnyPublisher()
            self?.refreshPublisher = publisher
            return publisher
        }
    }
}
