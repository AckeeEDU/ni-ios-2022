//
//  ContentView.swift
//  Tests
//
//  Created by Lukáš Hromadník on 06.04.2022.
//

import SwiftUI

struct WeatherResult: Codable {
    struct Forecast: Codable {
        let weatherStateName: String
        let applicableDate: String
    }

    let title: String
    let consolidatedWeather: [Forecast]
}

protocol APIServicing {
    func fetch(completion: @escaping (Result<WeatherResult, Error>) -> Void)
}

final class APIService: APIServicing {
    func fetch(completion: @escaping (Result<WeatherResult, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: URL(string: "https://www.metaweather.com/api/location/44418/")!) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else { return }

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase

                let decoded = try decoder.decode(WeatherResult.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

final class ContentViewModel: ObservableObject {
    @Published var text = ""
    @Published var errors: [String]?
    var weather: WeatherResult?

    private let api: APIServicing

    init(api: APIServicing) {
        self.api = api
    }

    func validate() {
        var errors: [String] = []

        if text.isEmpty {
            errors.append("Username cannot be empty")
        }

        if text.count < 3 {
            errors.append("Username has to have at least 3 characters")
        }

        if text.count > 8 {
            errors.append("Username has to have at most 8 characters")
        }

        let invalidSet = CharacterSet(charactersIn: "1234567890")

        if text.rangeOfCharacter(from: invalidSet) != nil {
            errors.append("Username cannot contain numbers")
        }

        self.errors = errors
    }

    func fetch(completion: @escaping () -> Void) {
        api.fetch { [weak self] result in
            switch result {
            case let .success(weather):
                self?.weather = weather

            case let .failure(error):
                print("[ERROR]", error.localizedDescription)
            }

            completion()
        }
    }
}

struct ContentView: View {
    @StateObject var viewModel: ContentViewModel

    var body: some View {
        VStack(spacing: 16) {
            TextField("Username", text: $viewModel.text)

            Button {
                viewModel.validate()
            } label: {
                Text("Validate!")
            }

            if let errors = viewModel.errors {
                if errors.isEmpty {
                    Text("Valid username")
                        .foregroundColor(.green)
                } else {
                    Text(errors[0])
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: ContentViewModel(api: APIService()))
    }
}
