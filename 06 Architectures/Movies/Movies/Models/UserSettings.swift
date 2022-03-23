//
//  UserSettings.swift
//  Movies
//
//  Created by Lukáš Hromadník on 22.03.2022.
//

import Foundation

struct UserSettings: Codable {
    struct User: Codable {
        let username: String
        let name: String
    }

    let user: User
}
