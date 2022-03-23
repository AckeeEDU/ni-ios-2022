//
//  API.swift
//  Movies
//
//  Created by Lukáš Hromadník on 22.03.2022.
//

import Foundation

struct API {
    let token: (String) async throws -> OAuthResponse
    let trending: (Int) async throws -> [PopularMovie]
    let detail: (String) async throws -> MovieDetail
    let settings: () async throws -> UserSettings
    let watchlist: (String) async throws -> [PopularMovie]
    let addToWatchlist: (Movie) async throws -> Void
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
            request.httpBody = try JSONSerialization.data(withJSONObject: body)

            let (data, _) = try await URLSession.shared.data(for: request)

            return try JSONDecoder.app.decode(OAuthResponse.self, from: data)
        },
        trending: { page in
            let query = page > 1 ? [URLQueryItem(name: "page", value: String(page))] : []

            return try await makeAuthenticatedRequest(path: "movies/trending", query: query)
        },
        detail: { id in
            try await makeAuthenticatedRequest(path: "movies/\(id)", query: [URLQueryItem(name: "extended", value: "full")])
        },
        settings: {
            try await makeAuthenticatedRequest(path: "users/settings")
        },
        watchlist: { userID in
            try await makeAuthenticatedRequest(path: "users/\(userID)/watchlist/movies/added")
        },
        addToWatchlist: { movie in
            let body: [String: [Movie]] = [
                "movies": [movie]
            ]
            var request = URLRequest(url: URL(string: "https://api.trakt.tv/sync/watchlist")!)
            request.httpMethod = "POST"
            request.httpBody = try JSONEncoder().encode(body)

            let data = try await makeRequest(request)

            return
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
) async throws -> Response {
    var components = URLComponents(
        url: URL(string: "https://api.trakt.tv/\(path)")!,
        resolvingAgainstBaseURL: false
    )
    if !query.isEmpty {
        components?.queryItems = query
    }

    guard let url = components?.url else { throw InvalidURL() }

    let data = try await makeRequest(URLRequest(url: url))

    return try JSONDecoder.app.decode(Response.self, from: data)
}

private func makeRequest(_ request: URLRequest) async throws -> Data {
    var request = request

    let headers = request.allHTTPHeaderFields ?? [:]
    let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
    request.allHTTPHeaderFields = headers.merging([
        "Authorization": "Bearer \(accessToken)",
        "Content-Type": "application/json",
        "trakt-api-version": "2",
        "trakt-api-key": "c97c817dedfab758e2d31af2323566f9872b8acfa438120466d09e4c7cb0c3ac"
    ], uniquingKeysWith: { $1 })

    var (data, response) = try await URLSession.shared.data(for: request)

    if (response as? HTTPURLResponse)?.statusCode == 403 {
        await updateToken()

        let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
        request.allHTTPHeaderFields = headers.merging(["Authorization": "Bearer \(accessToken)"], uniquingKeysWith: { $1 })

        (data, response) = try! await URLSession.shared.data(for: request)
    }

    print((response as? HTTPURLResponse)!.statusCode)
    print(String(data: data, encoding: .utf8)!)

    return data
}

private func updateToken() async {
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

    print(String(data: try! JSONSerialization.data(withJSONObject: body), encoding: .utf8)!)

    request.httpBody = try! JSONSerialization.data(withJSONObject: body)

    let (data, _) = try! await URLSession.shared.data(for: request)

    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    let response = try! decoder.decode(OAuthResponse.self, from: data)

    UserDefaults.standard.set(response.accessToken, forKey: "accessToken")
    UserDefaults.standard.set(response.refreshToken, forKey: "refreshToken")
}
