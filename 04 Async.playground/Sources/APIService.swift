import Combine
import Foundation

public protocol APIServicing {
    func feedPublisher() -> AnyPublisher<[Post], Never>
}

final class TestAPIService: APIServicing {
    let feedSubject = PassthroughSubject<[Post], Never>()
    
    func feedPublisher() -> AnyPublisher<[Post], Never> {
        feedSubject.eraseToAnyPublisher()
    }
}

public final class APIService: APIServicing {
    private let session = URLSession.shared
    
    public init() {
        
    }
    
//    public func feed(completion: @escaping (Result<[Post], Error>) -> ()) {
//        let url = URL(string: "https://fitstagram.ackee.cz/api/feed")!
//
//        session.dataTask(with: url) { data, _, error in
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//
//            guard let data = data else {
//                completion(.success([]))
//                return
//            }
//
//            do {
//                let posts = try JSONDecoder().decode([Post].self, from: data)
//                completion(.success(posts))
//            } catch {
//                completion(.failure(error))
//            }
//        }.resume()
//    }
    
    public func feedPublisher() -> AnyPublisher<[Post], Never> {
        let url = URL(string: "https://fitstagram.ackee.cz/api/feed")!
        return session.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [Post].self, decoder: JSONDecoder())
            .replaceError(with: [])
            .eraseToAnyPublisher()
//        Future { promise in
//            self.feed(completion: promise)
//        }
//        .replaceError(with: [])
//        .eraseToAnyPublisher()
    }
    
    
    
    
    
    
    
    
    
    public func comments(postID: String, completion: @escaping (Result<[Comment], Error>) -> ()) {
        let url = URL(string: "https://fitstagram.ackee.cz/api/feed/" + postID + "/comments")!
        
        session.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.success([]))
                return
            }
            
            do {
                let comments = try JSONDecoder().decode([Comment].self, from: data)
                completion(.success(comments))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    public func commentsPublisher(postID: String) -> AnyPublisher<[Comment], Never> {
        Future { promise in
            self.comments(postID: postID, completion: promise)
        }
        .replaceError(with: [])
        .eraseToAnyPublisher()
    }
}
