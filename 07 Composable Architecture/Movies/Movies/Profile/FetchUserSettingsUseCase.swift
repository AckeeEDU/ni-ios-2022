//
//  FetchUserSettingsUseCase.swift
//  Movies
//
//  Created by Lukáš Hromadník on 23.03.2022.
//

import Foundation

@dynamicCallable
protocol FetchUserSettingsUseCaseType {
    func fetch() async throws -> UserSettings
}

extension FetchUserSettingsUseCaseType {
    func dynamicallyCall(withArguments: [String]) async throws -> UserSettings {
        try await fetch()
    }
}

final class FetchUserSettingsUseCase: FetchUserSettingsUseCaseType {
    private let userSettingsRepository: UserSettingsRepositoryType

    init(userSettingsRepository: UserSettingsRepositoryType) {
        self.userSettingsRepository = userSettingsRepository
    }

    func fetch() async throws -> UserSettings {
        try await userSettingsRepository.fetch()
    }
}
