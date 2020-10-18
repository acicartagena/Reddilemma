// Copyright © 2020 ACartagena. All rights reserved.

import Foundation
import Combine
import AuthenticationServices

public class Authentication {
    public typealias AccessToken = String
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

    private var keychainStore: KeychainStoring
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    public convenience init() {
        self.init(keychainStore: KeychainStore())
    }

    init(keychainStore: KeychainStoring = KeychainStore()) {
        self.keychainStore = keychainStore
    }

    public func authorize(additionalScope: [Scope] = [], contextProviding: ASWebAuthenticationPresentationContextProviding?) -> AnyPublisher<AccessToken, AuthenticationError> {
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
            .map { [weak self] (response: AccessTokenResponse) -> String in
                self?.keychainStore.save(accessToken: response) // todo: figure out how to perform side effects (or better place to store this?)
                return response.accessToken
            }
            .eraseToAnyPublisher()
    }

    private func fetchAccessToken(code: String) -> AnyPublisher<AccessTokenResponse, AuthenticationError> {
        guard code != "" else { return Fail(error: AuthenticationError.noAccessToken).eraseToAnyPublisher() }
        let request = AccessTokenRequest(code: code).urlRequest
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap() { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                    httpResponse.statusCode == 200 else {
                        throw URLError(.badServerResponse)
                }
                return element.data
            }
        .decode(type: AccessTokenResponse.self, decoder: decoder)
        .mapError { error in AuthenticationError.accessToken(error) }
        .eraseToAnyPublisher()
    }

    public func refresh() -> AnyPublisher<RefreshTokenResponse, AuthenticationError> {
        let request = RefreshTokenRequest(refreshToken: keychainStore.refreshToken!).urlRequest

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap() { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                    httpResponse.statusCode == 200 else {
                        throw URLError(.badServerResponse)
                }
                return element.data
            }
        .decode(type: RefreshTokenResponse.self, decoder: decoder)
        .mapError { error in AuthenticationError.accessToken(error) }
        .map { [weak self] (response: RefreshTokenResponse) in
                self?.keychainStore.accessToken = response.accessToken
                return response
        }
        .eraseToAnyPublisher()
    }
}
