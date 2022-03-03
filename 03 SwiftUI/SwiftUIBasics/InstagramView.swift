
//  InstagramView.swift
//  03 SwiftUI
//
//  Created by Lukáš Hromadník on 03.03.2022.
//

import SwiftUI

struct InstagramView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("jmeno.uzivatele")
                .fontWeight(.semibold)
                .padding(.horizontal)

            Image(uiImage: UIImage(named: "calm")!)
                .resizable()
                .aspectRatio(contentMode: .fit)

            Group {
                HStack {
                    Button(
                        action: { },
                        label: {
                            Image(systemName: "heart")
                                .resizable()
                                .aspectRatio(1, contentMode: .fit)
                                .frame(width: 24)

                        }
                    )
                    Button(
                        action: { },
                        label: { Image(systemName: "message") }
                    )
                    Button(
                        action: { },
                        label: { Image(systemName: "paperplane") }
                    )

                    Spacer()

                    Button(
                        action: { },
                        label: {
                            Image(systemName: "bookmark")
                        }
                    )
                }


                Text("176 240 To se mi líbí")
                    .fontWeight(.semibold)

                Text("jmeno.uzivatele")
                    .fontWeight(.semibold)
                    .foregroundColor(.red)
                +

                Text(" Super popisek mého příspěvku na FITstagram")

                Button("Zobrazit všechny komentáře") { }
                .foregroundColor(.gray)
            }
            .padding(.horizontal)
        }
    }
}

struct InstagramView_Previews: PreviewProvider {
    static var previews: some View {
        InstagramView()
            .previewLayout(.sizeThatFits)
    }
}

