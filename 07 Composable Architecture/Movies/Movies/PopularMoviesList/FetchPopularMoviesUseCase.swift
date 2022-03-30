//
//  FetchPopularMoviesUseCase.swift
//  Movies
//
//  Created by Lukáš Hromadník on 23.03.2022.
//

import Foundation

@dynamicCallable
protocol FetchPopularMoviesUseCaseType {
    func fetchMovies(for page: Int) async throws -> [PopularMovie]
}

extension FetchPopularMoviesUseCaseType {
    func dynamicallyCall(withArguments arguments: [Int]) async throws -> [PopularMovie] {
        try await fetchMovies(for: arguments[0])
    }
}

final class FetchPopularMoviesUseCase: FetchPopularMoviesUseCaseType {
    private let popularMoviesRepository: PopularMoviesRepositoryType

    init(
        popularMoviesRepository: PopularMoviesRepositoryType
    ) {
        self.popularMoviesRepository = popularMoviesRepository
    }

    func fetchMovies(for page: Int) async throws -> [PopularMovie] {
        try await popularMoviesRepository.fetchPopularMovies(page: page)
    }
}
