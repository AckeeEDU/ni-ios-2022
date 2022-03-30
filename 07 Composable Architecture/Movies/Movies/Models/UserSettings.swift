//
//  UserSettings.swift
//  Movies
//
//  Created by Lukáš Hromadník on 22.03.2022.
//

import Foundation

struct UserSettings: Codable, Equatable {
    struct User: Codable, Equatable {
        let username: String
        let name: String
    }

    let user: User
}
