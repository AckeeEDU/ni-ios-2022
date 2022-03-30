//
//  PopularMoviesListStore.swift
//  Movies
//
//  Created by Lukáš Hromadník on 30.03.2022.
//

import ComposableArchitecture
import Foundation

struct PopularMoviesListEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let api: API
}

struct PopularMoviesListState: Equatable {
    var movies: [PopularMovie] = []
    var isLoading = false

    var page = 1
    var hasMoreContent = true
}

enum PopularMoviesListAction {
    case fetchData
    case fetchDataResponse(Result<[PopularMovie], Error>)
    case fetchNextDataIfNeeded(PopularMovie)
    case fetchNextDataResponse(Result<[PopularMovie], Error>)
}

let popularMoviesListReducer = Reducer<PopularMoviesListState, PopularMoviesListAction, PopularMoviesListEnvironment> { state, action, env in
    switch action {
    case .fetchData:
        return env.api.trending(state.page)
            .receive(on: env.mainQueue)
            .catchToEffect()
            .map(PopularMoviesListAction.fetchDataResponse)

    case let .fetchDataResponse(result):
        state.isLoading = false

        switch result {
        case let .failure(error):
            print("[ERROR]", error.localizedDescription)

        case let .success(movies):
            state.movies = movies
            state.hasMoreContent = !movies.isEmpty
            state.page += 1
        }

    case let .fetchNextDataIfNeeded(movie):
        guard state.movies.last?.id == movie.id else { break }

        state.isLoading = true

        return env.api.trending(state.page)
            .receive(on: env.mainQueue)
            .catchToEffect()
            .map(PopularMoviesListAction.fetchNextDataResponse)

    case let .fetchNextDataResponse(result):
        state.isLoading = false

        switch result {
        case let .failure(error):
            print("[ERROR]", error.localizedDescription)

        case let .success(movies):
            state.movies += movies
            state.hasMoreContent = !movies.isEmpty
            state.page += 1
        }
    }

    return .none
}


