//
//  MoviesListViewModel.swift
//  Accessibility-demo
//
//  Created by Igor Rosocha on 20.04.2022.
//

import Foundation

final class MoviesListViewModel {
    let movies: [Movie]
    
    // MARK: - Initialization

    init() {
        movies = Self.parseMovies().sorted { $0.title < $1.title }
    }
    
    // MARK: - Private helpers

    private static func parseMovies() -> [Movie] {
        let url = Bundle.main.url(forResource: "disneyPlusMoviesData", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let movies = try! JSONDecoder().decode(Movies.self, from: data).values
        
        return Array(movies)
    }
}
