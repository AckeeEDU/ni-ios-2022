//
//  RootStore.swift
//  Movies
//
//  Created by Lukáš Hromadník on 30.03.2022.
//

import ComposableArchitecture
import Foundation

struct RootEnvironment {

}

struct RootState: Equatable {
    var isLoading = false
    var isLoggedIn: Bool

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
}

let rootReducer = Reducer<RootState, RootAction, RootEnvironment> { state, action, env in
    switch action {
    case .login:
        break
    }

    return .none
}
