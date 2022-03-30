//
//  PopularMoviesRepository.swift
//  Movies
//
//  Created by Lukáš Hromadník on 23.03.2022.
//

import Foundation

protocol PopularMoviesRepositoryType {
    func fetchPopularMovies(page: Int) async throws -> [PopularMovie]
}

final class PopularMoviesRepository: PopularMoviesRepositoryType {
    private let api: API

    init(api: API) {
        self.api = api
    }

    func fetchPopularMovies(page: Int) async throws -> [PopularMovie] {
//        try await api.trending(page)
        return []
    }
}
