import Foundation

public struct User: Codable {
    public let id: String
    public let username: String
    public let firstName: String?
    public let lastName: String?
    public let avatar: URL?
    
    static var dummy: User {
        .init(
            id: "1",
            username: "olejnjak",
            firstName: nil,
            lastName: nil,
            avatar: nil
        )
    }
}
