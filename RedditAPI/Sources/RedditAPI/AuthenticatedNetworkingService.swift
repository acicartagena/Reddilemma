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
        let x: AnyPublisher<T, Error>? =
            tokenActions.token(forceRefresh: false)?
            .flatMap { [weak self] token in
                URLSession.shared.dataTaskPublisher(for: request)
                .tryMap() { element -> Data in
                    guard let httpResponse = element.response as? HTTPURLResponse,
                        httpResponse.statusCode == 200 else {
                            throw URLError(.badServerResponse)
                    }
                    return element.data
                }
                .decode(type: T.self, decoder: self?.decoder ?? JSONDecoder())
            }
            .tryCatch({ (error) -> AnyPublisher<Data, Error> in
                 
            })
            .eraseToAnyPublisher()



//        return URLSession.shared.dataTaskPublisher(for: request)
//            .tryMap() { element -> Data in
//                guard let httpResponse = element.response as? HTTPURLResponse,
//                    httpResponse.statusCode == 200 else {
//                        throw URLError(.badServerResponse)
//                }
//                return element.data
//            }
//            .decode(type: T.self, decoder: decoder)
//            .eraseToAnyPublisher()
    }

    private func publisher<T: Decodable>(for request: URLRequest, token: AccessToken) -> AnyPublisher<T, Error> {
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap() { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                    httpResponse.statusCode == 200 else {
                        throw URLError(.badServerResponse)
                }
                return element.data
            }
            .decode(type: T.self, decoder: decoder)
            .eraseToAnyPublisher()
    }

}
