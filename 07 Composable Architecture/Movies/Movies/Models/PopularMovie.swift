//
//  PopularMovie.swift
//  Movies
//
//  Created by Lukáš Hromadník on 22.03.2022.
//

import Foundation

struct PopularMovie: Codable, Identifiable, Equatable {
    let id = UUID()
    let movie: Movie
}
