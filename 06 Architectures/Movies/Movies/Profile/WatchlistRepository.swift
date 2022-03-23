//
//  WatchlistRepository.swift
//  Movies
//
//  Created by Lukáš Hromadník on 23.03.2022.
//

import Foundation

protocol WatchlistRepositoryType {
    func fetch() async throws -> [PopularMovie]
}

final class WatchlistRepository: WatchlistRepositoryType {
    private let api: API
    private let userSettingsRepository: UserSettingsRepositoryType

    init(
        api: API,
        userSettingsRepository: UserSettingsRepositoryType
    ) {
        self.api = api
        self.userSettingsRepository = userSettingsRepository
    }

    func fetch() async throws -> [PopularMovie] {
        guard let username = try await userSettingsRepository.username() else { return [] }
        return try await api.watchlist(username)
    }
}
