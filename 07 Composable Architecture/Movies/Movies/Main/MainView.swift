//
//  MainView.swift
//  Movies
//
//  Created by Lukáš Hromadník on 21.03.2022.
//

import SwiftUI
import ComposableArchitecture

struct MainView: View {
    private let store: Store<MainState, MainAction>
    @ObservedObject private var viewStore: ViewStore<MainState, MainAction>

    init(store: Store<MainState, MainAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        TabView {
            NavigationView {
                PopularMoviesListView(
                    store: store.scope(state: \.popularMoviesList, action: MainAction.popularMoviesList)
                )
            }
            .tabItem {
                Label("Popular", systemImage: "list.star")
            }

            NavigationView {
                ProfileView(
                    store: store.scope(state: \.profile, action: MainAction.profile)
                )
            }
            .tabItem {
                Label("Profile", systemImage: "person")
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(
            store: Store(
                initialState: MainState(),
                reducer: mainReducer,
                environment: MainEnvironment(
                    mainQueue: DispatchQueue.test.eraseToAnyScheduler(),
                    api: .live
                )
            )
        )
    }
}
