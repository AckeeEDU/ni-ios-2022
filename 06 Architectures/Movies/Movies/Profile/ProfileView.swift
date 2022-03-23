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

    @MainActor
    func refreshData() async {
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
                    .onAppear {
                        Task {
                            await viewModel.fetchData()
                        }
                    }
            }
        }
        .navigationTitle("Profile")
        .onAppear {
            Task {
                await viewModel.refreshData()
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
                    NavigationLink(
                        destination: MovieDetailView(
                            viewModel: MovieDetailViewModel(
                                movieID: movie.movie.ids.slug,
                                fetchMovieDetailUseCase: FetchMovieDetailUseCase(
                                    movieDetailRepository: MovieDetailRepository(
                                        api: .live
                                    )
                                ),
                                fetchWatchlistUseCase: FetchWatchlistUseCase(
                                    watchlistRepository: WatchlistRepository(
                                        api: .live,
                                        userSettingsRepository: UserSettingsRepository.live
                                    )
                                )
                            )
                        )
                    ) {
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
