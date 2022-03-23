//
//  MovieDetailView.swift
//  Movies
//
//  Created by Lukáš Hromadník on 22.03.2022.
//

import SwiftUI

struct MovieDetailView: View {
    let movieID: String
    @State var movie: MovieDetail?

    var body: some View {
        Group {
            if let movie = movie {
                contentView(movie)
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
                    .task {
                        movie = try! await API.live.detail(movieID)
                    }
            }
        }
        .navigationTitle("Movie detail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Task {
                        guard let movie = movie?.listObject else { return }
                        try! await API.live.addToWatchlist(movie)
                    }
                } label: {
                    Image(systemName: "star")
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
        MovieDetailView(movieID: "movie")
    }
}
