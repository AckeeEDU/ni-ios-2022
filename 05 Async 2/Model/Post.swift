import Foundation

public struct Post: Decodable {
    public let id: String
    public let author: User
    public let likes: [User]
    public let photos: [URL]
    public let text: String
    
    static var dummy: Post {
        .init(
            id: "1",
            author: .dummy,
            likes: [],
            photos: [],
            text: "Some text"
        )
    }
}
