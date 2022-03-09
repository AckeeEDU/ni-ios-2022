import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

let api = APIService()

api.feed { result in
    switch result {
    case .failure(let error):
        print("[FAILED]", error.localizedDescription)
    case .success(let posts):
        print("[SUCCESS]", posts.count)
    }
}
