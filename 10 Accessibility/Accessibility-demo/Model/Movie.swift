//
//  Movie.swift
//  Accessibility-demo
//
//  Created by Igor Rosocha on 19.04.2022.
//

import Foundation

struct Movie: Codable {
    let title: String
    let subtitle: String
    let description: String
    let cardImage: String
    let backgroundImage: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case subtitle = "subTitle"
        case description
        case cardImage = "cardImg"
        case backgroundImage = "backgroundImg"
    }
}

typealias Movies = [String: Movie]
