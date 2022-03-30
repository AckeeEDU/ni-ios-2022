//
//  Movie.swift
//  Movies
//
//  Created by Lukáš Hromadník on 22.03.2022.
//

import Foundation

struct Movie: Codable, Equatable {
    struct IDs: Codable, Equatable {
        let trakt: Int
        let slug: String
        let imdb: String
        let tmdb: Int
    }

    let ids: IDs
    let title: String
    let year: Int
}
