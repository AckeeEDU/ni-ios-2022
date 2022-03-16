import Foundation

public struct Comment: Decodable {
    public let id: String
    public let author: User
    public let text: String
    
    static var dummy: Comment {
        .init(
            id: "1",
            author: .dummy,
            text: "Some comment"
        )
    }
}
