import Combine
import Foundation

public protocol APIServicing {
    func feedPublisher() -> AnyPublisher<[Post], Error>
    func commentsPublisher(postID: String) -> AnyPublisher<[Comment], Error>
}

final class TestAPIService: APIServicing {
    var feedPublisherBody: () -> AnyPublisher<[Post], Error> = {
        Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func feedPublisher() -> AnyPublisher<[Post], Error> {
        feedPublisherBody()
    }
    
    var commentsPublisherBody: (String) -> AnyPublisher<[Comment], Error> = { _ in
        Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func commentsPublisher(postID: String) -> AnyPublisher<[Comment], Error> {
        commentsPublisherBody(postID)
    }
}

public final class APIService: APIServicing {
    private let session: URLSession = {
        var configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 1
        configuration.timeoutIntervalForResource = 1
        return URLSession(configuration: configuration)
    }()
    
    public init() {
        
    }
    
    public func feed(completion: @escaping (Result<[Post], Error>) -> ()) {
        let url = URL(string: "https://fitstagram.ackee.cz/api/feed")!

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
                let posts = try JSONDecoder().decode([Post].self, from: data)
                completion(.success(posts))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    public func feedPublisher() -> AnyPublisher<[Post], Error> {
        Future { promise in
            self.feed(completion: promise)
        }
        .delay(for: 2, scheduler: RunLoop.current)
        .eraseToAnyPublisher()
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
    
    public func commentsPublisher(postID: String) -> AnyPublisher<[Comment], Error> {
        Future { promise in
            self.comments(postID: postID, completion: promise)
        }
        .delay(for: 2, scheduler: RunLoop.current)
        .eraseToAnyPublisher()
    }
}
