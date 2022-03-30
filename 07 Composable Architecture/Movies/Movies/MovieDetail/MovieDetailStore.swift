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

struct MovieDetailState: Equatable {
    let movieID: String

    var movie: MovieDetail?
    var isInWatchlist = false
}

enum MovieDetailAction {
    case fetchData
    case toggleWatchlist

    case movieDetailResponse(Result<MovieDetail, Error>)
}

let movieDetailReducer = Reducer<MovieDetailState, MovieDetailAction, MovieDetailEnvironment> { state, action, env in
    switch action {
    case .fetchData:
        return env.api.detail(state.movieID)
            .receive(on: env.mainQueue)
            .catchToEffect()
            .map(MovieDetailAction.movieDetailResponse)

    case let .movieDetailResponse(result):
        switch result {
        case let .failure(error):
            print("[ERROR]", error.localizedDescription)

        case let .success(movieDetail):
            state.movie = movieDetail
        }

    case .toggleWatchlist:
        break
    }

    return .none
}
