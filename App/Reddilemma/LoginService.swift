// Copyright © 2020 ACartagena. All rights reserved.

import Foundation
import AuthenticationServices
import RedditAPI
import Combine

// NSObject for ASWebAuthenticationPresentationContextProviding
class LoginService: NSObject, ASWebAuthenticationPresentationContextProviding {
    private var cancellables: [AnyCancellable] = []
    private let authentication = Authentication()

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }

    func logIn() {
        authentication.authorize(contextProviding: self).sink(receiveCompletion: { (completion) in
            print("completion: \(completion)")
        }) { (accessToken) in
            print("accessToken: \(accessToken)")
        }.store(in: &cancellables)
    }

    func refresh() {
        authentication.refresh(using: "123").sink(receiveCompletion: { (completion) in
            print("completion: \(completion)")
        }) { response in
            print("response: \(response)")
        }.store(in: &cancellables)
    }
}
