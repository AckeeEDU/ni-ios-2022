//
//  OAuthResponse.swift
//  Movies
//
//  Created by Lukáš Hromadník on 22.03.2022.
//

import Foundation

struct OAuthResponse: Codable {
    let accessToken: String
    let refreshToken: String
}
