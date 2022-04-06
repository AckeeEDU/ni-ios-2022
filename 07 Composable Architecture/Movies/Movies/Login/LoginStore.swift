//
//  LoginStore.swift
//  Movies
//
//  Created by Lukáš Hromadník on 30.03.2022.
//

import ComposableArchitecture

struct LoginEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let api: API
}

struct LoginState: Equatable {
    var isLoading: Bool
    var isLoggedIn: Bool
}

extension LoginState {
    var loginURL: URL {
        var components = URLComponents(string: "https://trakt.tv/oauth/authorize")
        components?.queryItems = [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: "c97c817dedfab758e2d31af2323566f9872b8acfa438120466d09e4c7cb0c3ac"),
            URLQueryItem(name: "redirect_uri", value: "movies://login")
        ]

        return components!.url!
    }
}

enum LoginAction {
    case onOpenURL(URL)
    case tokenResponse(Result<OAuthResponse, RequestError>)
}

let loginReducer = Reducer<LoginState, LoginAction, LoginEnvironment> { state, action, env in
    switch action {
    case let .onOpenURL(url):
        state.isLoading = true

        // Parse the code from the given URL
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        guard let code = components?.queryItems?.first(where: { $0.name == "code" })?.value else { break }

        return env.api.token(code)
            .receive(on: env.mainQueue)
            .catchToEffect()
            .map(LoginAction.tokenResponse)

    case let .tokenResponse(result):
        switch result {
        case let .failure(error):
            print("[ERROR]", error.localizedDescription)

        case let .success(response):
            // Store the accessToken and refreshToken
            UserDefaults.standard.set(response.accessToken, forKey: "accessToken")
            UserDefaults.standard.set(response.refreshToken, forKey: "refreshToken")

            state.isLoggedIn = true
            state.isLoading = false
        }
    }

    return .none
}
