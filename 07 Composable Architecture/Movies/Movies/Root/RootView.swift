//
//  RootView.swift
//  Movies
//
//  Created by Lukáš Hromadník on 22.03.2022.
//

import SwiftUI
import ComposableArchitecture

struct RootView: View {
    private let store: Store<RootState, RootAction>
    @ObservedObject private var viewStore: ViewStore<RootState, RootAction>

    init(store: Store<RootState, RootAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        if viewStore.isLoggedIn {
            MainView(store: store.scope(state: \.main, action: RootAction.main))
        } else {
            LoginView(store: store.scope(state: \.login, action: RootAction.login))
        }
    }
}
