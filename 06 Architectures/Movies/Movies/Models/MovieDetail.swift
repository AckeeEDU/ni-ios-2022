//
//  MovieDetail.swift
//  Movies
//
//  Created by Lukáš Hromadník on 22.03.2022.
//

import Foundation

struct MovieDetail: Codable {
    let title: String
    let tagline: String
    let overview: String
    let released: String
    let runtime: Int
    let ids: Movie.IDs
    let year: Int
}

extension MovieDetail {
    var listObject: Movie {
        Movie(ids: ids, title: title, year: year)
    }
}
