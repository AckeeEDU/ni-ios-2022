//
//  MoviesApp.swift
//  Movies
//
//  Created by Lukáš Hromadník on 21.03.2022.
//

import SwiftUI
import ComposableArchitecture

@main
struct MoviesApp: App {
    private let rootStore = RootState()
    var body: some Scene {
        WindowGroup {
            RootView(
                store: Store(
                    initialState: rootStore,
                    reducer: rootReducer,
                    environment: RootEnvironment(
                        mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                        api: .live
                    )
                )
            )
        }
    }
}
