//
//  AsyncApp.swift
//  Shared
//
//  Created by Jakub Olejník on 16.03.2022.
//

import Shared
import SwiftUI
import WidgetKit

@main
struct AsyncApp: App {
    @State var isPresenting = false
    @State var postID = ""

    var body: some Scene {
        WindowGroup {
            FeedView(viewModel: .init(api: APIService()))
                .onAppear {
                    let ud = UserDefaults(suiteName: "group.cz.cvut.fit.Widget")!
                    FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.cz.cvut.fit.Widget")
                    ud.set(true, forKey: "key")
                    print("[KEY]", ud.bool(forKey: "key"))
                }
                .onOpenURL { url in
                    let widgetLink = WidgetLink(url: url)
                    postID = widgetLink.postID
                    isPresenting = true
                }
                .alert("Open", isPresented: $isPresenting) {

                } message: {
                    Text(postID)
                }

//            SomeView()
//                .onAppear {
//                    task()
//                }
        }
    }
}

struct SomeView: View {
    var body: some View {
        Text("Some View")
    }
}

let api = APIService()

func fetch() async throws {
    print("[START]")
    let posts = try await api.fetchFeed()
    let comments = try await api.fetchComments(postID: posts[0].id)
    
//    print("[POST]", posts.count)
//    print("[COMMENT]", comments.count)
    print("[END]")
}

func task() {
    Task {
        do {
            async let fetch1 = fetch()
            async let fetch2 = fetch()
            
            print(try await [fetch1, fetch2])
        } catch {
            print("[ERROR]", error)
        }
    }
}

//do {
//    let posts = try await fetchFeed()
//    print("SUCCESS", posts)
//} catch {
//    print("ERROR")
//}
 





