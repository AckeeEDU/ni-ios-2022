//
//  WatchlistRepository.swift
//  Movies
//
//  Created by Lukáš Hromadník on 23.03.2022.
//

import Foundation

protocol WatchlistRepositoryType {
    func fetch() async throws -> [PopularMovie]
    func removeFromWatchlist(_ movie: Movie) async throws
    func addToWatchlist(_ movie: Movie) async throws
    func watchlist() async throws -> [PopularMovie]
}

final class WatchlistRepository: WatchlistRepositoryType {
    static let live = WatchlistRepository(api: .live, userSettingsRepository: UserSettingsRepository.live)

    private var watchlist: [PopularMovie]?

    private let api: API
    private let userSettingsRepository: UserSettingsRepositoryType

    private init(
        api: API,
        userSettingsRepository: UserSettingsRepositoryType
    ) {
        self.api = api
        self.userSettingsRepository = userSettingsRepository
    }

    func fetch() async throws -> [PopularMovie] {
        guard let username = try await userSettingsRepository.username() else { return [] }
        let watchlist = try await api.watchlist(username)
        self.watchlist = watchlist
        return watchlist
    }

    func removeFromWatchlist(_ movie: Movie) async throws {
        try await api.removeFromWatchlist(movie)
    }

    func addToWatchlist(_ movie: Movie) async throws {
        try await api.addToWatchlist(movie)
    }

    func watchlist() async throws -> [PopularMovie] {
        if let watchlist = watchlist {
            return watchlist
        }

        return try await fetch()
    }
}
