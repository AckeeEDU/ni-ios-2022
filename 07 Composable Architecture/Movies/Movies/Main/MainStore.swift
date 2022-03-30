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

    var profile: ProfileEnvironment {
        .init(mainQueue: mainQueue, api: api)
    }
}

struct MainState: Equatable {
    var popularMoviesList = PopularMoviesListState()
    var profile = ProfileState()
}

enum MainAction {
    case popularMoviesList(PopularMoviesListAction)
    case profile(ProfileAction)
}

private let _mainReducer = Reducer<MainState, MainAction, MainEnvironment> { state, action, env in
    switch action {
    case .popularMoviesList, .profile:
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
    .combined(with: profileReducer.pullback(state: \.profile, action: /MainAction.profile, environment: \.profile))
