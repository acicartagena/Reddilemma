// Copyright © 2020 ACartagena. All rights reserved.

import Foundation
import Combine

public enum NetworkingError: Error {
    case invalidToken
    case badServerResponse
}

public protocol NetworkingActions {
    func httpRequest<T: Decodable>(for request: URLRequest) -> AnyPublisher<T, Error>
}

class Networking: NetworkingActions {
    static let shared = Networking()
    private init() { }
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    func httpRequest<T: Decodable>(for request: URLRequest) -> AnyPublisher<T, Error> {
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap() { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                    httpResponse.statusCode == 200 else {
                    throw NetworkingError.badServerResponse
                }
                return element.data
            }
            .decode(type: T.self, decoder: decoder)
            .eraseToAnyPublisher()
    }

}
