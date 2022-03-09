import Combine
import Foundation

let empty = Empty<Int, Error>(completeImmediately: false)
let just = Just(5)
let future = Future<Int, Error>.init { promise in
    promise(.success(1))
//    promise(.failure(NSError(domain: "", code: 0, userInfo: nil)))
}
