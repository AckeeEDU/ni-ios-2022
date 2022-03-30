//
//  UserSettingsRepository.swift
//  Movies
//
//  Created by Lukáš Hromadník on 23.03.2022.
//

import Foundation

protocol HasUserSettingsRepository {
    var userSettingsRepository: UserSettingsRepositoryType { get }
}

protocol UserSettingsRepositoryType {
    func fetch() async throws -> UserSettings
    func username() async throws -> String?
}

final class UserSettingsRepository: UserSettingsRepositoryType {
    typealias Dependencies = HasAPI

    private var username: String?
    private let dependencies: Dependencies

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    func fetch() async throws -> UserSettings {
//        let settings = try await dependencies.api.settings()
//        username = settings.user.username
//        return settings
        return UserSettings(user: UserSettings.User.init(username: "", name: ""))
    }

    func username() async throws -> String? {
        if let username = username {
            return username
        }

        return try await fetch().user.username
    }
}
