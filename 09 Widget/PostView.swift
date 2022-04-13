import Shared
import Combine
import SwiftUI

struct PostView: View {
    @ObservedObject var viewModel: PostViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(viewModel.post.text)
            Text(viewModel.post.author.username).italic()
            
            Group {
                switch viewModel.commentsState {
                case .loading:
                    ProgressView()
                case .error:
                    HStack(alignment: .center) {
                        Text("Nepodařilo se načíst počet komentářů")
                        Spacer()
                        Button(action: viewModel.fetchComments) {
                            Image(systemName: "arrow.counterclockwise")
                        }
                    }
                case .data(let comments):
                    Text("\(comments.count) komentářů")
                }
            }.frame(minHeight: 30)
        }.onAppear(perform: viewModel.fetchComments)
    }
}

struct PostView_Preview: PreviewProvider {
    static var previews: some View {
        let loadingAPI = TestAPIService()
        let loadingVM = PostViewModel(post: .dummy, api: loadingAPI)
        loadingAPI.commentsPublisherBody = { _ in Empty(completeImmediately: false).eraseToAnyPublisher() }
        
        let errorAPI = TestAPIService()
        let errorVM = PostViewModel(post: .dummy, api: errorAPI)
        errorAPI.commentsPublisherBody = { _ in
            Future { $0(.failure(NSError(domain: "", code: 0, userInfo: nil)))  }
                .eraseToAnyPublisher()
        }
        
        let dataAPI = TestAPIService()
        let dataVM = PostViewModel(post: .dummy, api: dataAPI)
        dataAPI.commentsPublisherBody = { _ in
            Just([.dummy])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return Group {
            PostView(viewModel: loadingVM)
                .previewLayout(.sizeThatFits)
            PostView(viewModel: errorVM)
                .previewLayout(.sizeThatFits)
            PostView(viewModel: dataVM)
                .previewLayout(.sizeThatFits)
        }
    }
}

@MainActor
final class PostViewModel: ObservableObject {
    @Published var commentsState = LoadingState<[Comment], Error>.data([])
    @Published var post: Post
    
    private let api: APIServicing
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializers
    
    init(post: Post, api: APIServicing) {
        self.post = post
        self.api = api
    }
    
    func fetchComments() {
        commentsState = .loading
        
        Task {
            do {
                let comments = try await api.fetchComments(postID: post.id)
                commentsState = .data(comments)
            } catch {
                commentsState = .error(error)
            }
        }
    }
}
