import Foundation

public final class APIService {
    private let session = URLSession.shared
    
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
}
