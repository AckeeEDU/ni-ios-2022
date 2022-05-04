//
//  ContentView.swift
//  FaceID
//
//  Created by Lukáš Hromadník on 04.05.2022.
//

import SwiftUI
import LocalAuthentication

struct ContentView: View {
    @State private var authenticated: Result<Void, Error>?

    var body: some View {
        VStack {
            Button(action: handleAuthentication) {
                Image(systemName: "faceid")
                    .resizable()
                    .frame(width: 32, height: 32)
            }

            switch authenticated {
            case .success:
                Text("Prošlo to")

            case let .failure(error):
                Text("ERROR! \(error.localizedDescription)")

            case .none:
                EmptyView()
            }
        }
    }

    private func handleAuthentication() {
        var error: NSError?
        let context = LAContext()
        let permissions = context.canEvaluatePolicy(
            .deviceOwnerAuthentication,
            error: &error
        )

        guard permissions else { return }

        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "FaceID login") { success, error in
            if let error = error {
                authenticated = .failure(error)
                return
            }

            if success {
                authenticated = .success(())
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
