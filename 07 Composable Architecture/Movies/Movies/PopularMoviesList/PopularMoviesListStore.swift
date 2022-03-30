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

extension PopularMoviesListEnvironment {
    var movieDetail: MovieDetailEnvironment {
        .init(mainQueue: mainQueue, api: api)
    }
}

@dynamicMemberLookup
struct PopularMoviesListState: Equatable {
    var userSettings: UserSettings?
    var watchlist: [PopularMovie]?
    var screenState: PopularMoviesListScreenState

    subscript<Value>(dynamicMember keyPath: WritableKeyPath<PopularMoviesListScreenState, Value>) -> Value {
        get { screenState[keyPath: keyPath] }
        set { screenState[keyPath: keyPath] = newValue }
    }

    subscript<Value>(dynamicMember keyPath: KeyPath<PopularMoviesListScreenState, Value>) -> Value {
        screenState[keyPath: keyPath]
    }
}

extension PopularMoviesListState {
    var movieDetail: MovieDetailState? {
        get {
            guard let state = screenState.movieDetailScreenState else { return nil }
            return .init(userSettings: userSettings, watchlist: watchlist, screenState: state)
        }
        set {
            userSettings = newValue?.userSettings
            watchlist = newValue?.watchlist
            screenState.movieDetailScreenState = newValue?.screenState
        }
    }
}

struct PopularMoviesListScreenState: Equatable {
    var movies: [PopularMovie] = []
    var isLoading = false

    var movieDetailScreenState: MovieDetailScreenState?

    fileprivate var page = 1
    fileprivate var hasMoreContent = true
}

extension PopularMoviesListScreenState {
    var isDetailShown: Bool {
        movieDetailScreenState != nil
    }
}

enum PopularMoviesListAction {
    case fetchData
    case fetchDataResponse(Result<[PopularMovie], Error>)
    case fetchNextDataIfNeeded(PopularMovie)
    case fetchNextDataResponse(Result<[PopularMovie], Error>)
    case showDetail(PopularMovie)
    case hideDetail

    case movieDetail(MovieDetailAction)
}

private let _popularMoviesListReducer = Reducer<PopularMoviesListState, PopularMoviesListAction, PopularMoviesListEnvironment> { state, action, env in
    switch action {
    case .fetchData:
        guard state.movies.isEmpty else { break }

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

    case let .showDetail(movie):
        state.movieDetailScreenState = MovieDetailScreenState(movieID: movie.movie.ids.slug)

    case .hideDetail:
        state.movieDetailScreenState = nil

    case .movieDetail:
        break
    }

    return .none
}

let popularMoviesListReducer = _popularMoviesListReducer
    .combined(
        with: movieDetailReducer
            .optional()
            .pullback(state: \.movieDetail, action: /PopularMoviesListAction.movieDetail, environment: \.movieDetail)
    )

