import Foundation

public struct Post: Decodable {
    public let id: String
    public let author: User
    public let likes: [User]
    public let photos: [URL]
    public let text: String
}

public struct User: Codable {
    public let username: String
    public let firstName: String?
    public let lastName: String?
    public let avatar: URL?
    public let id: String
}

public struct Comment: Decodable {
    public let id: String
    public let author: User
    public let text: String
}
