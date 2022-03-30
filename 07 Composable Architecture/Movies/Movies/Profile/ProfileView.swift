//
//  ProfileView.swift
//  Movies
//
//  Created by Lukáš Hromadník on 22.03.2022.
//

import SwiftUI
import ComposableArchitecture

struct ProfileView: View {
    private let store: ProfileStore
    @ObservedObject private var viewStore: ProfileViewStore

    init(store: ProfileStore) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        Group {
            if let userSettings = viewStore.userSettings {
                mainView(userSettings)
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
        .navigationTitle("Profile")
        .onAppear {
            viewStore.send(.fetchData)
        }
    }

    private func mainView(_ userSettings: UserSettings) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(userSettings.user.name)
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(userSettings.user.username)
                    .padding(.top, 8)

                Text("Watchlist")
                    .font(.headline)
                    .padding(.top, 32)

                ForEach(viewStore.watchlist) { movie in
                    NavigationLink(
                        isActive: viewStore.binding(
                            get: \.isMovieDetailShown,
                            send: { $0 ? .showMovieDetail(movie) : .hideMovieDetail }
                        ),
                        destination: { movieDetailView(movie) }
                    ) {
                        Text(movie.movie.title)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical)
                    }

                    Divider()
                }
            }
            .padding()
        }
    }

    private func movieDetailView(_ movie: PopularMovie) -> some View {
        IfLetStore(
            store.scope(state: \.movieDetail, action: ProfileAction.movieDetail),
            then: MovieDetailView.init
        )
    }
}
