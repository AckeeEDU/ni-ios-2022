//
//  LoginView.swift
//  Movies
//
//  Created by Lukáš Hromadník on 21.03.2022.
//

import SwiftUI

struct LoginView: View {
    @Binding var isLoading: Bool

    var body: some View {
        if isLoading {
            ProgressView()
                .progressViewStyle(.circular)
        } else {
            Link("Login", destination: loginURL)
        }
    }

    private var loginURL: URL {
        var components = URLComponents(string: "https://trakt.tv/oauth/authorize")
        components?.queryItems = [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: "c97c817dedfab758e2d31af2323566f9872b8acfa438120466d09e4c7cb0c3ac"),
            URLQueryItem(name: "redirect_uri", value: "movies://login")
        ]

        return components!.url!
    }
}
