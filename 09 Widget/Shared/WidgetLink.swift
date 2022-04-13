import Foundation

public struct WidgetLink {
    public let postID: String

    public var url: URL {
        URL(string: "widgetlink://" + postID)!
    }

    public init(url: URL) {
        postID = url.host!
    }

    public init(postID: String) {
        self.postID = postID
    }
}
