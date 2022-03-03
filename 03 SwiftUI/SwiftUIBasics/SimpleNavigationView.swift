//
//  SimpleNavigationView.swift
//  SwiftUIBasics
//
//  Created by Lukáš Hromadník on 03.03.2022.
//

import SwiftUI

struct SimpleNavigationView: View {
    @State private var isNextScreenShown = false

    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(
                    destination: { Text("Next screen") },
                    label: { Text("Go to next screen") }
                )

                // Programatic navigation using `NavigationLink` and
                // `isActive` bindin.
                NavigationLink(
                    isActive: $isNextScreenShown,
                    destination: { Text("Programatic navigation!") },
                    label: { EmptyView() }
                )

                // Two `NavigationLink`s can cause a lot of problems.
                // Adding another empty one will fix it.
                NavigationLink(destination: { EmptyView() }, label: { EmptyView() })

                Button {
                    //  the gievn block, after some time given as a parameter
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        isNextScreenShown = true
                    }
                } label: {
                    Text("GO to next screen programatically")
                }
            }
        }
    }
}
