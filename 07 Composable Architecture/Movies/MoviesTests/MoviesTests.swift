//
//  MoviesTests.swift
//  MoviesTests
//
//  Created by Lukáš Hromadník on 06.04.2022.
//

import XCTest
import ComposableArchitecture
import Combine
@testable import Movies

let encanto = MovieDetail(title: "Encanto", tagline: "blabla!", overview: "overview", released: "2022", runtime: 100, ids: .init(trakt: 0, slug: "encanto", imdb: "", tmdb: 0), year: 2022)
let novak = UserSettings(user: UserSettings.User(username: "jan.novak", name: "Jan Novák"))
let popularEncanto = PopularMovie(movie: encanto.listObject)

extension API {
    static var mock: API = API(
        token: { _ in fatalError() },
        trending: { _ in fatalError() },
        detail: { _ in Just(encanto).setFailureType(to: RequestError.self).eraseToAnyPublisher() },
        settings: { Just(novak).setFailureType(to: RequestError.self).eraseToAnyPublisher() },
        watchlist: { _ in Just([popularEncanto]).setFailureType(to: RequestError.self).eraseToAnyPublisher() },
        addToWatchlist: { _ in fatalError() },
        removeFromWatchlist: { _ in fatalError() }
    )
}

class MovieDetailStoreTests: XCTestCase {
    func testSomething() {
        let scheduler = DispatchQueue.test
        let store = TestStore(
            initialState: MovieDetailState(
                userSettings: nil,
                watchlist: nil,
                screenState: MovieDetailScreenState(
                    movieID: "encanto"
                )
            ),
            reducer: movieDetailReducer,
            environment: MovieDetailEnvironment(
                mainQueue: scheduler.eraseToAnyScheduler(),
                api: .mock
            )
        )

        store.send(.fetchData)
        scheduler.advance()
        store.receive(.movieDetailResponse(.success(encanto))) {
            $0.movie = encanto
        }
        store.receive(.userSettingsResponse(.success(novak))) {
            $0.userSettings = novak
        }
        store.receive(.watchlistResponse(.success([popularEncanto]))) {
            $0.watchlist = [popularEncanto]
        }
        store.receive(.updateWatchlist) {
            $0.isInWatchlist = true
        }
    }
}
