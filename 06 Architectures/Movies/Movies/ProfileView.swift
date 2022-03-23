//
//  ProfileView.swift
//  Movies
//
//  Created by Lukáš Hromadník on 22.03.2022.
//

import SwiftUI

struct ProfileView: View {
    @State var isLoading = true
    @State var userSettings: UserSettings?
    @State var watchlist: [PopularMovie] = []

    var body: some View {
        Group {
            if let userSettings = userSettings {
                mainView(userSettings)
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
                    .task {
                        let userSettings = try! await API.live.settings()
                        watchlist = try! await API.live.watchlist(userSettings.user.username)
                        self.userSettings = userSettings
                    }
            }
        }
        .navigationTitle("Profile")
        .task {
            guard let username = userSettings?.user.username else { return }
            watchlist = try! await API.live.watchlist(username)
        }
    }

    private func mainView(_ userSettings: UserSettings) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(userSettings.user.name)
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(userSettings.user.username)
                    .padding(.top, 8)

                Text("Watchlist")
                    .font(.headline)
                    .padding(.top, 32)

                ForEach(watchlist) { movie in
                    NavigationLink(destination: MovieDetailView(movieID: movie.movie.ids.slug)) {
                        Text(movie.movie.title)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical)
                    }

                    Divider()
                }
            }
            .padding()
        }
    }
}
