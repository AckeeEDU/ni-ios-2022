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
                    viewModel: ProfileViewModel(
                        fetchUserSettingsUseCase: FetchUserSettingsUseCase(
                            userSettingsRepository: dependencies.userSettingsRepository
                        ),
                        fetchWatchlistUseCase: FetchWatchlistUseCase(
                            watchlistRepository: dependencies.watchlistRepository
                        )
                    )
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
