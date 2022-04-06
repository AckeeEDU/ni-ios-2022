//
//  MovieDetailStore.swift
//  Movies
//
//  Created by Lukáš Hromadník on 30.03.2022.
//

import Foundation
import ComposableArchitecture

struct MovieDetailEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let api: API
}

@dynamicMemberLookup
struct MovieDetailState: Equatable {
    var userSettings: UserSettings?
    var watchlist: [PopularMovie]?

    var screenState: MovieDetailScreenState

    subscript<Value>(dynamicMember keyPath: WritableKeyPath<MovieDetailScreenState, Value>) -> Value {
        get { screenState[keyPath: keyPath] }
        set { screenState[keyPath: keyPath] = newValue }
    }

    subscript<Value>(dynamicMember keyPath: KeyPath<MovieDetailScreenState, Value>) -> Value {
        screenState[keyPath: keyPath]
    }
}

struct MovieDetailScreenState: Equatable {
    let movieID: String
    var movie: MovieDetail?
    var isInWatchlist = false
}

enum MovieDetailAction: Equatable {
    case fetchData
    case toggleWatchlist
    case updateWatchlist

    case movieDetailResponse(Result<MovieDetail, RequestError>)
    case userSettingsResponse(Result<UserSettings, RequestError>)
    case watchlistResponse(Result<[PopularMovie], RequestError>)
    case removeFromWatchlistResponse(Result<Int, RequestError>)
    case addToWatchlistResponse(Result<Int, RequestError>)
}

let movieDetailReducer = Reducer<MovieDetailState, MovieDetailAction, MovieDetailEnvironment> { state, action, env in
    switch action {
    case .fetchData:
        var effects: [Effect<MovieDetailAction, Never>] = []
        effects.append(
            env.api.detail(state.movieID)
                .receive(on: env.mainQueue)
                .catchToEffect()
                .map(MovieDetailAction.movieDetailResponse)
        )

        if state.userSettings == nil {
            effects.append(
                env.api.settings()
                    .receive(on: env.mainQueue)
                    .catchToEffect()
                    .map(MovieDetailAction.userSettingsResponse)
            )
        } else {
            effects.append(Effect(value: .updateWatchlist))
        }

        return .merge(effects)

    case let .movieDetailResponse(result):
        switch result {
        case let .failure(error):
            print("[ERROR]", error.localizedDescription)

        case let .success(movieDetail):
            state.movie = movieDetail
        }

    case let .userSettingsResponse(result):
        switch result {
        case let .failure(error):
            print("[ERROR]", error.localizedDescription)

        case let .success(settings):
            state.userSettings = settings

            return env.api.watchlist(settings.user.username)
                .receive(on: env.mainQueue)
                .catchToEffect()
                .map(MovieDetailAction.watchlistResponse)
        }

    case let .watchlistResponse(result):
        switch result {
        case let .failure(error):
            print("[ERROR]", error.localizedDescription)

        case let .success(watchlist):
            state.watchlist = watchlist
            return Effect(value: .updateWatchlist)
        }

    case .updateWatchlist:
        state.isInWatchlist = state.watchlist?.contains { $0.movie.ids.slug == state.movieID } ?? false

    case .toggleWatchlist:
        guard let movie = state.movie?.listObject else { break }

        if state.isInWatchlist {
            return env.api.removeFromWatchlist(movie)
                .map { _ in 0 }
                .receive(on: env.mainQueue)
                .catchToEffect()
                .map(MovieDetailAction.removeFromWatchlistResponse)
        } else {
            return env.api.addToWatchlist(movie)
                .map { _ in 0 }
                .receive(on: env.mainQueue)
                .catchToEffect()
                .map(MovieDetailAction.addToWatchlistResponse)
        }

    case let .addToWatchlistResponse(result), let .removeFromWatchlistResponse(result):
        switch result {
        case let .failure(error):
            print("[ERROR]", error.localizedDescription)

        case let .success(watchlist):
            guard let username = state.userSettings?.user.username else { break }
            return env.api.watchlist(username)
                .receive(on: env.mainQueue)
                .catchToEffect()
                .map(MovieDetailAction.watchlistResponse)
        }
    }

    return .none
}
