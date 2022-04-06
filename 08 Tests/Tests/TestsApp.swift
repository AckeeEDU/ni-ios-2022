//
//  TestsApp.swift
//  Tests
//
//  Created by Lukáš Hromadník on 06.04.2022.
//

import SwiftUI

@main
struct TestsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: ContentViewModel(api: APIService()))
        }
    }
}
