//
//  PopularMoviesListView.swift
//  Movies
//
//  Created by Lukáš Hromadník on 22.03.2022.
//

import SwiftUI

final class PopularMoviesListViewModel: ObservableObject {
    @Published var movies: [PopularMovie] = []
    @Published var isLoading = false

    private var page = 1
    private var hasMoreContent = true

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

        let movies = try! await API.live.trending(page)

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
    @StateObject var viewModel: PopularMoviesListViewModel

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(viewModel.movies) { movie in
                    NavigationLink {
                        MovieDetailView(viewModel: MovieDetailViewModel(movieID: movie.movie.ids.slug))
                    } label: {
                        popularMovieItem(movie)
                    }
                    .task {
                        await viewModel.fetchNextMoviesIfNeeded(movie)
                    }
                }

                if viewModel.isLoading {
                    loadingView
                }
            }
        }
        .task {
            await viewModel.fetchData()
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
}
