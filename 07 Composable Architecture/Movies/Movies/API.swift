//
//  API.swift
//  Movies
//
//  Created by Lukáš Hromadník on 22.03.2022.
//

import Foundation
import Combine

struct RequestError: Error, Equatable {
    let error: Error

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.localizedDescription == rhs.localizedDescription
    }
}

protocol HasAPI {
    var api: API { get }
}

struct API {
    let token: (String) -> AnyPublisher<OAuthResponse, RequestError>
    let trending: (Int) -> AnyPublisher<[PopularMovie], RequestError>
    let detail: (String) -> AnyPublisher<MovieDetail, RequestError>
    let settings: () -> AnyPublisher<UserSettings, RequestError>
    let watchlist: (String) -> AnyPublisher<[PopularMovie], RequestError>
    let addToWatchlist: (Movie) -> AnyPublisher<Void, RequestError>
    let removeFromWatchlist: (Movie) -> AnyPublisher<Void, RequestError>
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
                .mapError(RequestError.init)
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
) -> AnyPublisher<Response, RequestError> {
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
        .mapError(RequestError.init)
        .eraseToAnyPublisher()
}

private func makeRequest(_ request: URLRequest) -> AnyPublisher<Data, RequestError> {
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
        .mapError(RequestError.init)
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
