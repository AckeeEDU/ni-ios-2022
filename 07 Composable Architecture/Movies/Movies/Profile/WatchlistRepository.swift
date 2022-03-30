//
//  WatchlistRepository.swift
//  Movies
//
//  Created by Lukáš Hromadník on 23.03.2022.
//

import Foundation

protocol HasWatchlistRepository {
    var watchlistRepository: WatchlistRepositoryType { get }
}

protocol WatchlistRepositoryType {
    func fetch() async throws -> [PopularMovie]
    func removeFromWatchlist(_ movie: Movie) async throws
    func addToWatchlist(_ movie: Movie) async throws
    func watchlist() async throws -> [PopularMovie]
}

final class WatchlistRepository: WatchlistRepositoryType {
    typealias Dependencies = HasAPI & HasUserSettingsRepository
    private var watchlist: [PopularMovie]?

    private let dependencies: Dependencies

    init(
        dependencies: Dependencies
    ) {
        self.dependencies = dependencies
    }

    func fetch() async throws -> [PopularMovie] {
//        guard let username = try await dependencies.userSettingsRepository.username() else { return [] }
//        let watchlist = try await dependencies.api.watchlist(username)
//        self.watchlist = watchlist
//        return watchlist
        return []
    }

    func removeFromWatchlist(_ movie: Movie) async throws {
//        try await dependencies.api.removeFromWatchlist(movie)
    }

    func addToWatchlist(_ movie: Movie) async throws {
//        try await dependencies.api.addToWatchlist(movie)
    }

    func watchlist() async throws -> [PopularMovie] {
        if let watchlist = watchlist {
            return watchlist
        }

        return try await fetch()
    }
}
