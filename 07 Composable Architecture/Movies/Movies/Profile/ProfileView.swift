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

    private let fetchUserSettingsUseCase: FetchUserSettingsUseCaseType
    private let fetchWatchlistUseCase: FetchWatchlistUseCaseType

    init(
        fetchUserSettingsUseCase: FetchUserSettingsUseCaseType,
        fetchWatchlistUseCase: FetchWatchlistUseCaseType
    ) {
        self.fetchUserSettingsUseCase = fetchUserSettingsUseCase
        self.fetchWatchlistUseCase = fetchWatchlistUseCase
    }

    @MainActor
    func fetchData() async {
        userSettings = try! await fetchUserSettingsUseCase()
        watchlist = try! await fetchWatchlistUseCase()
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
            }
        }
        .navigationTitle("Profile")
        .onAppear {
            Task {
                await viewModel.fetchData()
            }
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
                    NavigationLink(destination: movieDetailView(movie)) {
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

    private func movieDetailView(_ movie: PopularMovie) -> some View {
        EmptyView()
//        MovieDetailView(
//            store:
//            viewModel: MovieDetailViewModel(
//                movieID: movie.movie.ids.slug,
//                fetchMovieDetailUseCase: FetchMovieDetailUseCase(
//                    movieDetailRepository: MovieDetailRepository(
//                        api: .live
//                    )
//                ),
//                fetchWatchlistUseCase: FetchWatchlistUseCase(
//                    watchlistRepository: dependencies.watchlistRepository
//                ),
//                toggleWatchlistUseCase: ToggleWatchlistUseCase(
//                    watchlistRepository: dependencies.watchlistRepository
//                )
//            )
//        )
    }
}
