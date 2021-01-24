// Copyright © 2020 ACartagena. All rights reserved.

import Foundation
import Combine

class AuthenticatedNetworking: NetworkingActions {
    static let shared = AuthenticatedNetworking()
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    private let tokenActions: TokenActions
    private init(tokenActions: TokenActions = TokenService()) {
        self.tokenActions = tokenActions
    }

    func httpRequest<T: Decodable>(for request: URLRequest) -> AnyPublisher<T, Error> {
        return tokenActions.token(forceRefresh: false)
            .flatMap { token in
                self.publisher(for: request, token: token)
            }
            .tryCatch({ (error) -> AnyPublisher<T, Error> in
                guard let networkingError = error as? NetworkingError,
                      case .invalidToken = networkingError else { throw error }
                let y: AnyPublisher<T, Error> =
                    self.tokenActions.token(forceRefresh: true)
                    .flatMap({ token in
                        self.publisher(for: request, token: token)
                    }).eraseToAnyPublisher()
                return y

            })
            .eraseToAnyPublisher()
    }

    private func publisher<T: Decodable>(for request: URLRequest, token: AccessToken) -> AnyPublisher<T, Error> {
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap() { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse else {
                    throw NetworkingError.badServerResponse
                }
                switch httpResponse.statusCode {
                case 401: throw NetworkingError.invalidToken
                case 200: return element.data
                default: throw NetworkingError.badServerResponse
                }

            }
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }

}
