//
//  MovieDetailRepository.swift
//  Movies
//
//  Created by Lukáš Hromadník on 23.03.2022.
//

import Foundation

protocol MovieDetailRepositoryType {
    func fetchDetail(id: String) async throws -> MovieDetail
}

final class MovieDetailRepository: MovieDetailRepositoryType {
    private let api: API

    init(api: API) {
        self.api = api
    }

    func fetchDetail(id: String) async throws -> MovieDetail {
//        try await api.detail(id)
        return MovieDetail(title: "", tagline: "", overview: "", released: "", runtime: 0, ids: .init(trakt: 0, slug: "", imdb: "", tmdb: 0), year: 0)
    }
}
