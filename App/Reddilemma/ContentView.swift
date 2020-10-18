// Copyright © 2020 ACartagena. All rights reserved.

import SwiftUI

struct ContentView: View {
    let loginService = LoginService()

    var body: some View {
        VStack {
            Button("Login") {
                self.login()
            }
            Button("Refresh") {
                self.refresh()
            }
        }

    }

    func login() {
        loginService.logIn()
    }

    func refresh() {
        loginService.refresh()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
