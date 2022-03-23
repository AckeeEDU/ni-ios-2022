//
//  FetchMovieDetailUseCase.swift
//  Movies
//
//  Created by Lukáš Hromadník on 23.03.2022.
//

import Foundation

@dynamicCallable
protocol FetchMovieDetailUseCaseType {
    func fetch(id: String) async throws -> MovieDetail
}

extension FetchMovieDetailUseCaseType {
    func dynamicallyCall(withArguments arguments: [String]) async throws -> MovieDetail {
        try await fetch(id: arguments[0])
    }
}

final class FetchMovieDetailUseCase: FetchMovieDetailUseCaseType {
    private let movieDetailRepository: MovieDetailRepositoryType

    init(
        movieDetailRepository: MovieDetailRepositoryType
    ) {
        self.movieDetailRepository = movieDetailRepository
    }

    func fetch(id: String) async throws -> MovieDetail {
        try await movieDetailRepository.fetchDetail(id: id)
    }
}
