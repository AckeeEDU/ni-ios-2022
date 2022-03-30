//
//  ProfileStore.swift
//  Movies
//
//  Created by Lukáš Hromadník on 30.03.2022.
//

import Foundation
import ComposableArchitecture

typealias ProfileStore = Store<ProfileState, ProfileAction>
typealias ProfileViewStore = ViewStore<ProfileState, ProfileAction>

struct ProfileEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let api: API
}

extension ProfileEnvironment {
    var movieDetail: MovieDetailEnvironment {
        .init(mainQueue: mainQueue, api: api)
    }
}

struct ProfileState: Equatable {
    var isLoading = true
    var userSettings: UserSettings?
    var watchlist: [PopularMovie] = []

    var movieDetail: MovieDetailState?
}

extension ProfileState {
    var isMovieDetailShown: Bool {
        movieDetail != nil
    }
}

enum ProfileAction {
    case fetchData
    case userSettingsResponse(Result<UserSettings, Error>)
    case watchlistResponse(Result<[PopularMovie], Error>)
    case showMovieDetail(PopularMovie)
    case hideMovieDetail

    case movieDetail(MovieDetailAction)
}

private let _profileReducer = Reducer<ProfileState, ProfileAction, ProfileEnvironment> { state, action, env in
    switch action {
    case .fetchData:
        return env.api.settings()
            .receive(on: env.mainQueue)
            .catchToEffect()
            .map(ProfileAction.userSettingsResponse)

    case let .userSettingsResponse(result):

        switch result {
        case let .failure(error):
            state.isLoading = false
            print("[ERROR]", error.localizedDescription)

        case let .success(settings):
            state.userSettings = settings

            return env.api.watchlist(settings.user.username)
                .receive(on: env.mainQueue)
                .catchToEffect()
                .map(ProfileAction.watchlistResponse)
        }

    case let .watchlistResponse(result):
        state.isLoading = false
        switch result {
        case let .failure(error):
            print("[ERROR]", error.localizedDescription)

        case let .success(movies):
            state.watchlist = movies
        }

    case let .showMovieDetail(movie):
        state.movieDetail = MovieDetailState(movieID: movie.movie.ids.slug)

    case .hideMovieDetail:
        state.movieDetail = nil

    case .movieDetail:
        break
    }

    return .none
}

let profileReducer = _profileReducer
    .combined(with: movieDetailReducer
        .optional()
        .pullback(state: \.movieDetail, action: /ProfileAction.movieDetail, environment: \.movieDetail)
    )
