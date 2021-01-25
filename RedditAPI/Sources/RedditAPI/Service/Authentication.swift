// Copyright © 2020 ACartagena. All rights reserved.

import Foundation
import Combine
import AuthenticationServices

public class Authentication {
//    public typealias AccessToken = String
    public enum AuthenticationError: Swift.Error {
        case authorize(Error)
        case accessToken(Error)
        case noAccessToken
        case refreshToken(Error)
    }

    private enum Constants {
        static let code = "code"
        static let state = "TEST"
    }
    private typealias AuthorizationCode = String

    private var refreshToken = ""

    private let scheme = Secrets.scheme

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    private let networking: NetworkingActions
    private var keychainStore: KeychainStoring

    public convenience init() {
        self.init(networking: Networking.shared, keychainStore: KeychainStore.shared)
    }

    init(networking: Networking, keychainStore: KeychainStoring) {
        self.networking = networking
        self.keychainStore = keychainStore
    }

    public func authorize(additionalScope: [Scope] = [], contextProviding: ASWebAuthenticationPresentationContextProviding?) -> AnyPublisher<AuthenticationToken, AuthenticationError> {
        let authorize = Future<AuthorizationCode, AuthenticationError> { [weak self] completion in
            let authURL = AuthorizeRequest(state: Constants.state, scope: additionalScope).url
            let authSession = ASWebAuthenticationSession(url: authURL, callbackURLScheme: self?.scheme) { (url, error) in
                if let error = error {
                    completion(.failure(AuthenticationError.authorize(error)))
                } else if let url = url {
                    let queryItems = URLComponents(string: url.absoluteString)?.queryItems
                    let code = queryItems?.filter { $0.name == Constants.code }.first?.value ?? ""
                    completion(.success(code))
                }
            }

            authSession.presentationContextProvider = contextProviding
            authSession.prefersEphemeralWebBrowserSession = true
            authSession.start()
        }

        return authorize
            .flatMap(fetchAccessToken)
            .map {
                let authenticationToken = AuthenticationToken(response: $0)
                self.keychainStore.refreshToken = authenticationToken.refreshToken // TODO: refreshToken is saved as a side effect
                self.keychainStore.accessToken = authenticationToken.token // TODO: accessToken is saved as a side effect
                return authenticationToken
            }
            .eraseToAnyPublisher()
    }

    private func fetchAccessToken(code: String) -> AnyPublisher<AccessTokenResponse, AuthenticationError> {
        guard code != "" else { return Fail(error: AuthenticationError.noAccessToken).eraseToAnyPublisher() }
        let urlRequest = AccessTokenRequest(code: code).urlRequest
        return (networking.httpRequest(for: urlRequest) as AnyPublisher<AccessTokenResponse, Error>)
            .mapError { error in AuthenticationError.accessToken(error) }
            .eraseToAnyPublisher()
    }

    public func refresh() -> AnyPublisher<AccessToken, AuthenticationError> {
        return TokenService().token(forceRefresh: true)
            .mapError { error in AuthenticationError.accessToken(error) }
            .eraseToAnyPublisher()
    }
}
