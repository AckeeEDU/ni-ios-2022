//
//  MovieDetailView.swift
//  Movies
//
//  Created by Lukáš Hromadník on 22.03.2022.
//

import SwiftUI
import ComposableArchitecture

//final class MovieDetailViewModel: ObservableObject {
//    @Published var movie: MovieDetail?
//    @Published var isInWatchlist = false
//
//    private let movieID: String
//    private let fetchMovieDetailUseCase: FetchMovieDetailUseCaseType
//    private let fetchWatchlistUseCase: FetchWatchlistUseCaseType
//    private let toggleWatchlistUseCase: ToggleWatchlistUseCaseType
//
//    init(
//        movieID: String,
//        fetchMovieDetailUseCase: FetchMovieDetailUseCaseType,
//        fetchWatchlistUseCase: FetchWatchlistUseCaseType,
//        toggleWatchlistUseCase: ToggleWatchlistUseCaseType
//    ) {
//        self.movieID = movieID
//        self.fetchMovieDetailUseCase = fetchMovieDetailUseCase
//        self.fetchWatchlistUseCase = fetchWatchlistUseCase
//        self.toggleWatchlistUseCase = toggleWatchlistUseCase
//    }
//
//    @MainActor
//    func fetchData() async {
//        movie = try! await fetchMovieDetailUseCase(movieID)
//        await updateWatchlistStatus()
//    }
//
//    @MainActor
//    func toggleWatchlist() async {
//        guard let movie = movie else { return }
//
//        try! await toggleWatchlistUseCase(movie)
//        await updateWatchlistStatus()
//    }
//
//    @MainActor
//    private func updateWatchlistStatus() async {
//        let watchlist = try! await fetchWatchlistUseCase()
//        isInWatchlist = watchlist.contains { $0.movie.ids.trakt == movie?.ids.trakt }
//    }
//}

struct MovieDetailView: View {
    private let store: Store<MovieDetailState, MovieDetailAction>
    @ObservedObject private var viewStore: ViewStore<MovieDetailState, MovieDetailAction>

    init(store: Store<MovieDetailState, MovieDetailAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        Group {
            if let movie = viewStore.movie {
                contentView(movie)
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
                    .onAppear {
                        viewStore.send(.fetchData)
                    }
            }
        }
        .navigationTitle("Movie detail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewStore.send(.toggleWatchlist)
                } label: {
                    if viewStore.isInWatchlist {
                        Image(systemName: "star.fill")
                    } else {
                        Image(systemName: "star")
                    }
                }
            }
        }
    }

    private func contentView(_ movie: MovieDetail) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text(movie.title)
                    .font(.title)

                Text(movie.tagline)
                    .font(.headline)

                Label(movie.released, systemImage: "calendar")

                Label(String(movie.runtime) + " min", systemImage: "timer")

                Text(movie.overview)
            }
            .padding()
        }
    }
}
