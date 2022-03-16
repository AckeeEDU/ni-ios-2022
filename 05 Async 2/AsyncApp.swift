//
//  AsyncApp.swift
//  Shared
//
//  Created by Jakub Olejník on 16.03.2022.
//

import SwiftUI

@main
struct AsyncApp: App {
    var body: some Scene {
        WindowGroup {
            FeedView(viewModel: .init(api: APIService()))
        }
    }
}
