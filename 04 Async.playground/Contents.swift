import Foundation
import PlaygroundSupport
import Combine
import UIKit

PlaygroundPage.current.needsIndefiniteExecution = true

let api = APIService()

let array2D = [[1], [2]]
let array = array2D.flatMap { $0 }

//api.feed { result in
//    switch result {
//    case .failure(let error):
//        print("[FAILED]", error.localizedDescription)
//    case .success(let posts):
//        print("[CLOSURE][SUCCESS]", posts.count)
//    }
//}

struct EmptyStringError: Error { }

//let feedPublisher = api.feedPublisher().merge(with: api.feedPublisher())
//    .sink { <#[Post]#> in
//        <#code#>
//    }

let subject = PassthroughSubject<String, Never>()
let currentValueSubject = CurrentValueSubject<String, Never>("username")
currentValueSubject.value



let username: AnyPublisher<String, Never> = subject.eraseToAnyPublisher()
let password: AnyPublisher<String, Never> = Just("password").eraseToAnyPublisher()
let consent: AnyPublisher<Bool, Never> = Just(false).eraseToAnyPublisher()

let isEnabled = username.combineLatest(password, consent)
    .handleEvents(receiveOutput: {
        print($0)
    })
    .map { username, password, consent in
    !username.isEmpty && !password.isEmpty && consent
}.eraseToAnyPublisher().eraseToAnyPublisher()
    .sink { print($0) }

//subject.send("username")
//subject.send("username2")
//subject.send("username3")

//let commentsPublisher = feedPublisher.flatMap { posts in
//    api.commentsPublisher(postID: posts[0].id)
//}
//
//let cancellable = commentsPublisher.sink {
//    print("[COMMENTS]", $0.count)
//}


