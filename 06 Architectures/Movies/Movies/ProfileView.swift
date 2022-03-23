//
//  ProfileView.swift
//  Movies
//
//  Created by Lukáš Hromadník on 22.03.2022.
//

import SwiftUI

final class ProfileViewModel: ObservableObject {
    @Published var isLoading = true
    @Published var userSettings: UserSettings?
    @Published var watchlist: [PopularMovie] = []

    @MainActor
    func fetchData() async {
        let userSettings = try! await API.live.settings()
        watchlist = try! await API.live.watchlist(userSettings.user.username)
        self.userSettings = userSettings
    }

    @MainActor
    func refreshData() async {
        guard let username = userSettings?.user.username else { return }
        watchlist = try! await API.live.watchlist(username)
    }
}

struct ProfileView: View {
    @StateObject var viewModel: ProfileViewModel

    var body: some View {
        Group {
            if let userSettings = viewModel.userSettings {
                mainView(userSettings)
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
                    .task {
                        await viewModel.fetchData()
                    }
            }
        }
        .navigationTitle("Profile")
        .task {
            await viewModel.refreshData()
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

                ForEach(viewModel.watchlist) { movie in
                    NavigationLink(destination: MovieDetailView(viewModel: MovieDetailViewModel(movieID: movie.movie.ids.slug))) {
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
