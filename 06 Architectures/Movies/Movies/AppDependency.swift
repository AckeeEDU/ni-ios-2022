//
//  AppDependency.swift
//  Movies
//
//  Created by Lukáš Hromadník on 23.03.2022.
//

import Foundation

final class AppDependency {
    fileprivate init() { }

    lazy var watchlistRepository: WatchlistRepositoryType = WatchlistRepository(dependencies: self)
    lazy var api: API = .live
    lazy var userSettingsRepository: UserSettingsRepositoryType = UserSettingsRepository(dependencies: self)
}

extension AppDependency: HasWatchlistRepository { }
extension AppDependency: HasUserSettingsRepository { }
extension AppDependency: HasAPI { }

let dependencies = AppDependency()
