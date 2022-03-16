import Combine
import SwiftUI

struct FeedView: View {
    @ObservedObject var viewModel: FeedViewModel
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView()
            case .data(let posts):
                List(posts, id: \.id) { post in
                    PostView(viewModel: .init(post: post, api: viewModel.api))
                }
            case .error:
                VStack(spacing: 20) {
                    Text("Data se nepodařilo načíst")
                    Button(action: viewModel.fetchFeed) {
                        Image(systemName: "arrow.counterclockwise")
                    }
                }
            }
        }.onAppear(perform: viewModel.fetchFeed)
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        let loadingAPI = TestAPIService()
        let loadingVM = FeedViewModel(api: loadingAPI)
        loadingAPI.feedPublisherBody = { Empty(completeImmediately: false).eraseToAnyPublisher() }
        
        let errorAPI = TestAPIService()
        let errorVM = FeedViewModel(api: errorAPI)
        errorAPI.feedPublisherBody = {
            Future { $0(.failure(NSError(domain: "", code: 0, userInfo: nil)))  }
                .eraseToAnyPublisher()
        }
        
        let dataAPI = TestAPIService()
        let dataVM = FeedViewModel(api: dataAPI)
        dataAPI.feedPublisherBody = {
            Just([.dummy])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return Group {
            FeedView(viewModel: loadingVM)
            FeedView(viewModel: errorVM)
            FeedView(viewModel: dataVM)
        }
    }
}

final class FeedViewModel: ObservableObject {
    @Published fileprivate(set) var state = LoadingState<[Post], Error>.data([])
    
    let api: APIServicing
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializers
    
    init(api: APIServicing) {
        self.api = api
    }
    
    func fetchFeed() {
        state = .loading
        
        api.feedPublisher()
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    if self?.state.isLoading == true {
                        self?.state = .data([])
                    }
                case .failure(let error):
                    self?.state =  .error(error)
                }
            } receiveValue: { [weak self] posts in
                self?.state = .data(posts)
            }
            .store(in: &cancellables)
    }
}
