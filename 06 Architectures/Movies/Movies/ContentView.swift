//
//  ContentView.swift
//  Movies
//
//  Created by Lukáš Hromadník on 21.03.2022.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationView {
                PopularMoviesListView(viewModel: PopularMoviesListViewModel())
            }
            .tabItem {
                Label("Popular", systemImage: "list.star")
            }

            NavigationView {
                ProfileView(
                    viewModel: ProfileViewModel(
                        fetchUserSettingsUseCase: FetchUserSettingsUseCase(
                            userSettingsRepository: UserSettingsRepository.live
                        ),
                        fetchWatchlistUseCase: FetchWatchlistUseCase(
                            watchlistRepository: WatchlistRepository(
                                api: .live,
                                userSettingsRepository: UserSettingsRepository.live
                            )
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
