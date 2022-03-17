import PlaygroundSupport
import UIKit

PlaygroundPage.current.needsIndefiniteExecution = true

let api = APIService()

func fetch() async throws {
    print("[START]")
    let posts = try await api.fetchFeed()
    let comments = try await api.fetchComments(postID: posts[0].id)
    
//    print("[POST]", posts.count)
//    print("[COMMENT]", comments.count)
    print("[END]")
}

Task {
    do {
        async let fetch1 = fetch()
        async let fetch2 = fetch()

        print(try await [fetch1, fetch2])
    } catch {
        print("[ERROR]", error)
    }
}

//do {
//    let posts = try await fetchFeed()
//    print("SUCCESS", posts)
//} catch {
//    print("ERROR")
//}
 
