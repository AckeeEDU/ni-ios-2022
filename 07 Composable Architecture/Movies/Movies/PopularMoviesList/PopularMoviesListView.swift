//
//  PopularMoviesListView.swift
//  Movies
//
//  Created by Lukáš Hromadník on 22.03.2022.
//

import SwiftUI
import ComposableArchitecture

final class PopularMoviesListViewModel: ObservableObject {
    @Published var movies: [PopularMovie] = []
    @Published var isLoading = false

    private var page = 1
    private var hasMoreContent = true
    private let fetchPopularMoviesUseCase: FetchPopularMoviesUseCaseType

    init(
        fetchPopularMoviesUseCase: FetchPopularMoviesUseCaseType
    ) {
        self.fetchPopularMoviesUseCase = fetchPopularMoviesUseCase
    }

    func fetchData() async {
        guard movies.isEmpty else { return }
        await fetchMovies(clean: true)
    }

    @MainActor
    func fetchNextMoviesIfNeeded(_ item: PopularMovie) async {
        guard movies.last?.id == item.id else { return }

        isLoading = true
        await fetchMovies()
        isLoading = false
    }

    @MainActor
    private func fetchMovies(clean: Bool = false) async {
        guard clean || hasMoreContent else { return }

        let movies = try! await fetchPopularMoviesUseCase(page)

        guard !movies.isEmpty else {
            hasMoreContent = false
            return
        }

        if clean {
            self.movies = movies
            page = 1
        } else {
            self.movies += movies
        }

        page += 1
    }
}

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
                    NavigationLink(destination: movieDetailView(movie)) {
                        popularMovieItem(movie)
                    }
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

    private func movieDetailView(_ movie: PopularMovie) -> MovieDetailView {
        MovieDetailView(
            viewModel: MovieDetailViewModel(
                movieID: movie.movie.ids.slug,
                fetchMovieDetailUseCase: FetchMovieDetailUseCase(
                    movieDetailRepository: MovieDetailRepository(
                        api: .live
                    )
                ),
                fetchWatchlistUseCase: FetchWatchlistUseCase(
                    watchlistRepository: dependencies.watchlistRepository
                ),
                toggleWatchlistUseCase: ToggleWatchlistUseCase(
                    watchlistRepository: dependencies.watchlistRepository
                )
            )
        )
    }
}
