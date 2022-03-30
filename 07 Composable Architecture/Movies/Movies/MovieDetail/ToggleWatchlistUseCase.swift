//
//  ToggleWatchlistUseCase.swift
//  Movies
//
//  Created by Lukáš Hromadník on 23.03.2022.
//

import Foundation

@dynamicCallable
protocol ToggleWatchlistUseCaseType {
    func toggle(_ movie: MovieDetail) async throws
}

extension ToggleWatchlistUseCaseType {
    func dynamicallyCall(withArguments arguments: [MovieDetail]) async throws {
        try await toggle(arguments[0])
    }
}

final class ToggleWatchlistUseCase: ToggleWatchlistUseCaseType {
    private let watchlistRepository: WatchlistRepositoryType

    init(
        watchlistRepository: WatchlistRepositoryType
    ) {
        self.watchlistRepository = watchlistRepository
    }

    func toggle(_ movie: MovieDetail) async throws {
        if try await watchlistRepository.watchlist().contains(where: { $0.movie.ids.slug == movie.listObject.ids.slug }) {
            try await watchlistRepository.removeFromWatchlist(movie.listObject)
        } else {
            try await watchlistRepository.addToWatchlist(movie.listObject)
        }
    }
}
