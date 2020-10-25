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

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    public init() { }

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
            .map { AuthenticationToken(response: $0) }
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

    public func refresh(using refreshToken: String) -> AnyPublisher<AccessToken, AuthenticationError> {
        let request = RefreshTokenRequest(refreshToken: refreshToken).urlRequest

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
        .map { $0.accessToken }
        .eraseToAnyPublisher()
    }
}
