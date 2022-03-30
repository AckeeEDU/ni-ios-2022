//
//  LoginView.swift
//  Movies
//
//  Created by Lukáš Hromadník on 21.03.2022.
//

import SwiftUI
import ComposableArchitecture

struct LoginView: View {
    private let store: Store<LoginState, LoginAction>
    @ObservedObject private var viewStore: ViewStore<LoginState, LoginAction>

    init(store: Store<LoginState, LoginAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        Group {
            if viewStore.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
            } else {
                Link("Login", destination: viewStore.loginURL)
            }
        }
        .onOpenURL {
            viewStore.send(.onOpenURL($0))
        }
    }
}
