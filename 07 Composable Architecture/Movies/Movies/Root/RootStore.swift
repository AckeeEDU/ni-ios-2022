//
//  RootStore.swift
//  Movies
//
//  Created by Lukáš Hromadník on 30.03.2022.
//

import ComposableArchitecture
import Foundation

struct RootEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let api: API
}

extension RootEnvironment {
    var main: MainEnvironment {
        .init(mainQueue: mainQueue, api: api)
    }

    var login: LoginEnvironment {
        .init(mainQueue: mainQueue, api: api)
    }
}

struct RootState: Equatable {
    var isLoading = false
    var isLoggedIn: Bool
    var main = MainState()

    init() {
        self.isLoggedIn = !(UserDefaults.standard.string(forKey: "accessToken") ?? "").isEmpty
    }
}

extension RootState {
    var login: LoginState {
        get {
            LoginState(isLoading: isLoading, isLoggedIn: isLoggedIn)
        }
        set {
            isLoading = newValue.isLoading
            isLoggedIn = newValue.isLoggedIn
        }
    }
}

enum RootAction {
    case login(LoginAction)
    case main(MainAction)
}

private let _rootReducer = Reducer<RootState, RootAction, RootEnvironment> { state, action, env in
    switch action {
    case .login, .main:
        break
    }

    return .none
}

let rootReducer = _rootReducer
    .combined(
        with: mainReducer.pullback(
            state: \.main,
            action: /RootAction.main,
            environment: \.main
        )
    )
    .combined(
        with: loginReducer.pullback(
            state: \.login,
            action: /RootAction.login,
            environment: \.login
        )
    )
