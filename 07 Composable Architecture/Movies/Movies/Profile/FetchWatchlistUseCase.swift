//
//  FetchWatchlistUseCase.swift
//  Movies
//
//  Created by Lukáš Hromadník on 23.03.2022.
//

import Foundation

@dynamicCallable
protocol FetchWatchlistUseCaseType {
    func fetch() async throws -> [PopularMovie]
}

extension FetchWatchlistUseCaseType {
    func dynamicallyCall(withArguments: [String]) async throws -> [PopularMovie] {
        try await fetch()
    }
}

final class FetchWatchlistUseCase: FetchWatchlistUseCaseType {
    private let watchlistRepository: WatchlistRepositoryType

    init(
        watchlistRepository: WatchlistRepositoryType
    ) {
        self.watchlistRepository = watchlistRepository
    }

    func fetch() async throws -> [PopularMovie] {
        try await watchlistRepository.fetch()
    }
}
