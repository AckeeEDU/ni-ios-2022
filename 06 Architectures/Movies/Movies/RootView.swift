//
//  RootView.swift
//  Movies
//
//  Created by Lukáš Hromadník on 22.03.2022.
//

import SwiftUI

struct RootView: View {
    @State var isLoading = false
    @State var isLoggedIn: Bool = false

    init() {
        _isLoggedIn = State(initialValue: !(UserDefaults.standard.string(forKey: "accessToken") ?? "").isEmpty)
    }

    var body: some View {
        if isLoggedIn {
            ContentView()
        } else {
            loginView
        }
    }

    private var loginView: some View {
        LoginView(isLoading: $isLoading)
            .onOpenURL { url in
                isLoading = true

                // Parse the code from the given URL
                let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
                guard let code = components?.queryItems?.first(where: { $0.name == "code" })?.value else { return }

                Task {
                    // Obtain an access token for the given code
                    let response = try! await API.live.token(code)

                    // Store the accessToken and refreshToken
                    UserDefaults.standard.set(response.accessToken, forKey: "accessToken")
                    UserDefaults.standard.set(response.refreshToken, forKey: "refreshToken")

                    // Move to the app
                    isLoggedIn = true
                    isLoading = false
                }
            }
    }
}
