//
//  PopularMoviesListView.swift
//  Movies
//
//  Created by Lukáš Hromadník on 22.03.2022.
//

import SwiftUI
import ComposableArchitecture

struct PopularMoviesListView: View {
    private let store: Store<PopularMoviesListState, PopularMoviesListAction>
    @ObservedObject private var viewStore: ViewStore<PopularMoviesListState, PopularMoviesListAction>

    init(store: Store<PopularMoviesListState, PopularMoviesListAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(viewStore.movies) { movie in
                    NavigationLink(
                        isActive: viewStore.binding(
                            get: \.isDetailShown,
                            send: { $0 ? .showDetail(movie) : .hideDetail }
                        ),
                        destination: { movieDetailView(movie) },
                        label: { popularMovieItem(movie) }
                    )
                    .onAppear {
                        viewStore.send(.fetchNextDataIfNeeded(movie))
                    }
                }

                if viewStore.isLoading {
                    loadingView
                }
            }
        }
        .onAppear {
            viewStore.send(.fetchData)
        }
        .navigationTitle("Popular movies")
    }

    private func popularMovieItem(_ movie: PopularMovie) -> some View {
        VStack(alignment: .leading) {
            Text(movie.movie.title)
                .multilineTextAlignment(.leading)
                .font(.headline)
                .padding(.horizontal)

            Text(String(movie.movie.year))
                .padding(.horizontal)

            Divider()
        }
    }

    private var loadingView: some View {
        ProgressView()
            .progressViewStyle(.circular)
            .frame(maxWidth: .infinity)
            .padding()
    }

    private func movieDetailView(_ movie: PopularMovie) -> some View {
        IfLetStore(
            store.scope(state: \.movieDetail, action: PopularMoviesListAction.movieDetail),
            then: MovieDetailView.init
        )
    }
}
