//
//  MainStore.swift
//  Movies
//
//  Created by Lukáš Hromadník on 30.03.2022.
//

import ComposableArchitecture
import Foundation

struct MainEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let api: API
}

extension MainEnvironment {
    var popularMoviesList: PopularMoviesListEnvironment {
        .init(mainQueue: mainQueue, api: api)
    }
}

struct MainState: Equatable {
    var popularMoviesList = PopularMoviesListState()
}

extension MainState {
}

enum MainAction {
    case popularMoviesList(PopularMoviesListAction)
}

private let _mainReducer = Reducer<MainState, MainAction, MainEnvironment> { state, action, env in
    switch action {
    case .popularMoviesList:
        break
    }

    return .none
}

let mainReducer = _mainReducer
    .combined(
        with: popularMoviesListReducer.pullback(
            state: \.popularMoviesList,
            action: /MainAction.popularMoviesList,
            environment: \.popularMoviesList
        )
    )
