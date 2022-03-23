//
//  MovieDetailView.swift
//  Movies
//
//  Created by Lukáš Hromadník on 22.03.2022.
//

import SwiftUI

final class MovieDetailViewModel: ObservableObject {
    @Published var movie: MovieDetail?
    @Published var isInWatchlist = false

    private let movieID: String

    init(movieID: String) {
        self.movieID = movieID
    }

    @MainActor
    func fetchData() async {
        movie = try! await API.live.detail(movieID)
        await updateWatchlistStatus()
    }

    @MainActor
    func toggleWatchlist() async {
        guard let movie = movie?.listObject else { return }
        if isInWatchlist {
            try! await API.live.removeFromWatchlist(movie)
        } else {
            try! await API.live.addToWatchlist(movie)
        }
        await updateWatchlistStatus()
    }

    @MainActor
    private func updateWatchlistStatus() async {
        let settings = try! await API.live.settings()
        let username = settings.user.username
        let watchlist = try! await API.live.watchlist(username)
        isInWatchlist = watchlist.contains { $0.movie.ids.trakt == movie?.ids.trakt }
    }
}

struct MovieDetailView: View {
    @StateObject var viewModel: MovieDetailViewModel

    var body: some View {
        Group {
            if let movie = viewModel.movie {
                contentView(movie)
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
                    .onAppear {
                        Task {
                            await viewModel.fetchData()
                        }
                    }
            }
        }
        .navigationTitle("Movie detail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Task {
                        await viewModel.toggleWatchlist()
                    }
                } label: {
                    if viewModel.isInWatchlist {
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

struct MovieDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MovieDetailView(viewModel: MovieDetailViewModel(movieID: "movie"))
    }
}
