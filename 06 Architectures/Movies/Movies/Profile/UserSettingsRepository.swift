//
//  UserSettingsRepository.swift
//  Movies
//
//  Created by Lukáš Hromadník on 23.03.2022.
//

import Foundation

protocol UserSettingsRepositoryType {
    func fetch() async throws -> UserSettings
    func username() async throws -> String?
}

final class UserSettingsRepository: UserSettingsRepositoryType {
    private var username: String?

    private let api: API

    static let live = UserSettingsRepository(api: .live)

    init(api: API) {
        self.api = api
    }

    func fetch() async throws -> UserSettings {
        let settings = try await api.settings()
        username = settings.user.username
        return settings
    }

    func username() async throws -> String? {
        if let username = username {
            return username
        }

        return try await fetch().user.username
    }
}
