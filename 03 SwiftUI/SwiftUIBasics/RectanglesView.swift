//
//  RectanglesView.swift
//  SwiftUIBasics
//
//  Created by Lukáš Hromadník on 03.03.2022.
//

import SwiftUI

struct RectanglesView: View {
    @State private var useRectanglesOnBackground = false

    var body: some View {
        VStack(spacing: 0) {
            textWithRectanglesOnBackground
            textAsOverlays
        }
    }

    private var textWithRectanglesOnBackground: some View {
        GeometryReader { proxy in
            HStack(spacing: 16) {
                Text("Ahoj")
                    .padding()
                    .frame(width: (proxy.size.width - 32) / 3)
                    .background(.red)

                Text("Jak se")
                    .padding()
                    .frame(width: (proxy.size.width - 32) / 3)
                    .background(.red)

                Text("Máš")
                    .padding()
                    .frame(width: (proxy.size.width - 32) / 3)
                    .background(.red)

            }
        }
    }

    private var textAsOverlays: some View {
        HStack(spacing: 16) {
            Rectangle()
                .fill(.red)
                .overlay(Text("Ahoj"))

            Rectangle()
                .fill(.red)
                .overlay(Text("Jak se"))

            Rectangle()
                .fill(.red)
                .overlay(Text("Máš"))
        }
    }
}

struct RectanglesView_Previews: PreviewProvider {
    static var previews: some View {
        RectanglesView()
    }
}
