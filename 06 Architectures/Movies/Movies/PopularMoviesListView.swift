//
//  PopularMoviesListView.swift
//  Movies
//
//  Created by Lukáš Hromadník on 22.03.2022.
//

import SwiftUI

struct PopularMoviesListView: View {
    @State var movies: [PopularMovie] = []
    @State var isLoading = false
    @State var page = 1
    @State var hasMoreContent = true

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(movies) { movie in
                    NavigationLink {
                        MovieDetailView(movieID: movie.movie.ids.slug)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(movie.movie.title)
                                .font(.headline)
                                .padding(.horizontal)

                            Text(String(movie.movie.year))
                                .padding(.horizontal)

                            Divider()
                        }
                    }
                    .onAppear {
                        fetchNextMoviesIfNeeded(movie)
                    }
                }

                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
        }
        .task {
            guard movies.isEmpty else { return }
            await fetchMovies(clean: true)
        }
        .navigationTitle("Popular movies")
    }

    private func fetchNextMoviesIfNeeded(_ item: PopularMovie) {
        if movies.last?.id == item.id {
            isLoading = true
            Task {
                await fetchMovies()
                isLoading = false
            }
        }
    }

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
