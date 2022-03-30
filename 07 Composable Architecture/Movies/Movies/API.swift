//
//  API.swift
//  Movies
//
//  Created by Lukáš Hromadník on 22.03.2022.
//

import Foundation
import Combine

protocol HasAPI {
    var api: API { get }
}

struct API {
    let token: (String) -> AnyPublisher<OAuthResponse, Error>
    let trending: (Int) -> AnyPublisher<[PopularMovie], Error>
    let detail: (String) -> AnyPublisher<MovieDetail, Error>
    let settings: () -> AnyPublisher<UserSettings, Error>
    let watchlist: (String) -> AnyPublisher<[PopularMovie], Error>
    let addToWatchlist: (Movie) -> AnyPublisher<Void, Error>
    let removeFromWatchlist: (Movie) -> AnyPublisher<Void, Error>
}

extension API {
    static let live: API = .init(
        token: { code in
            let url = URL(string: "https://api.trakt.tv/oauth/token")!

            var request = URLRequest(url: url)
            request.httpMethod = "POST"

            let headers = request.allHTTPHeaderFields ?? [:]
            request.allHTTPHeaderFields = headers.merging(["Content-Type": "application/json"], uniquingKeysWith: { $1 })
            let body = [
                "code": code,
                "client_id": "c97c817dedfab758e2d31af2323566f9872b8acfa438120466d09e4c7cb0c3ac",
                "client_secret": "9eb5191557cd0205c42851b83ba75c4b5f2a2b29cd4b547fe6e90c0e1f1a4b63",
                "grant_type": "authorization_code",
                "redirect_uri": "movies://login",
            ]
            request.httpBody = try! JSONSerialization.data(withJSONObject: body)

            return URLSession.shared.dataTaskPublisher(for: request)
                .map(\.data)
                .decode(type: OAuthResponse.self, decoder: JSONDecoder.app)
                .eraseToAnyPublisher()
        },
        trending: { page in
            let query = page > 1 ? [URLQueryItem(name: "page", value: String(page))] : []

            return makeAuthenticatedRequest(path: "movies/trending", query: query)
        },
        detail: { id in
            makeAuthenticatedRequest(path: "movies/\(id)", query: [URLQueryItem(name: "extended", value: "full")])
        },
        settings: {
            makeAuthenticatedRequest(path: "users/settings")
        },
        watchlist: { userID in
            makeAuthenticatedRequest(path: "users/\(userID)/watchlist/movies/added")
        },
        addToWatchlist: { movie in
            let body: [String: [Movie]] = [
                "movies": [movie]
            ]
            var request = URLRequest(url: URL(string: "https://api.trakt.tv/sync/watchlist")!)
            request.httpMethod = "POST"
            request.httpBody = try! JSONEncoder().encode(body)

            return makeRequest(request)
                .map { _ in }
                .eraseToAnyPublisher()
        },
        removeFromWatchlist: { movie in
            let body: [String: [Movie]] = [
                "movies": [movie]
            ]
            var request = URLRequest(url: URL(string: "https://api.trakt.tv/sync/watchlist/remove")!)
            request.httpMethod = "POST"
            request.httpBody = try! JSONEncoder().encode(body)

            return makeRequest(request)
                .map { _ in }
                .eraseToAnyPublisher()
        }
    )
}

extension JSONDecoder {
    static let app: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}

struct InvalidURL: Error { }

private func makeAuthenticatedRequest<Response: Decodable>(
    path: String,
    query: [URLQueryItem] = []
) -> AnyPublisher<Response, Error> {
    var components = URLComponents(
        url: URL(string: "https://api.trakt.tv/\(path)")!,
        resolvingAgainstBaseURL: false
    )
    if !query.isEmpty {
        components?.queryItems = query
    }

    guard let url = components?.url else { fatalError() }

    return makeRequest(URLRequest(url: url))
        .decode(type: Response.self, decoder: JSONDecoder.app)
        .eraseToAnyPublisher()
}

private func makeRequest(_ request: URLRequest) -> AnyPublisher<Data, Error> {
    dataRequest(for: request)
        .tryCatch { error -> AnyPublisher<(data: Data, response: URLResponse), Error> in
            if error.code == .init(rawValue: 403) {
                return updateToken()
                    .flatMap {
                        dataRequest(for: request)
                            .mapError { $0 as Error }
                    }
                    .eraseToAnyPublisher()
            } else {
                return Fail(error: error)
                    .eraseToAnyPublisher()
            }
        }
        .map(\.data)
        .eraseToAnyPublisher()
}

private func dataRequest(for request: URLRequest) -> URLSession.DataTaskPublisher {
    var request = request

    let headers = request.allHTTPHeaderFields ?? [:]
    let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
    request.allHTTPHeaderFields = headers.merging([
        "Authorization": "Bearer \(accessToken)",
        "Content-Type": "application/json",
        "trakt-api-version": "2",
        "trakt-api-key": "c97c817dedfab758e2d31af2323566f9872b8acfa438120466d09e4c7cb0c3ac"
    ], uniquingKeysWith: { $1 })

    return URLSession.shared.dataTaskPublisher(for: request)
}

private func updateToken() -> AnyPublisher<Void, Error> {
    let url = URL(string: "https://api.trakt.tv/oauth/token")!

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    let headers = request.allHTTPHeaderFields ?? [:]
    request.allHTTPHeaderFields = headers.merging(["Content-Type": "application/json"], uniquingKeysWith: { $1 })
    let body = [
        "refresh_token": UserDefaults.standard.string(forKey: "refreshToken") ?? "",
        "client_id": "c97c817dedfab758e2d31af2323566f9872b8acfa438120466d09e4c7cb0c3ac",
        "client_secret": "9eb5191557cd0205c42851b83ba75c4b5f2a2b29cd4b547fe6e90c0e1f1a4b63",
        "grant_type": "refresh_token"
    ]

    request.httpBody = try! JSONSerialization.data(withJSONObject: body)

    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase

    return URLSession.shared.dataTaskPublisher(for: request)
        .map(\.data)
        .decode(type: OAuthResponse.self, decoder: decoder)
        .handleEvents(
            receiveOutput: { response in
                UserDefaults.standard.set(response.accessToken, forKey: "accessToken")
                UserDefaults.standard.set(response.refreshToken, forKey: "refreshToken")
            }
        )
        .map { _ in }
        .eraseToAnyPublisher()
}
