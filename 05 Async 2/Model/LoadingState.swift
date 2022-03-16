import Foundation

enum LoadingState<Model, Error: Swift.Error> {
    case loading
    case error(Error)
    case data(Model)
    
    var error: Error? {
        switch self {
        case let .error(error): return error
        default: return nil
        }
    }
    
    var isLoading: Bool {
        switch self {
        case .loading: return true
        default: return false
        }
    }
    
    var data: Model? {
        switch self {
        case let .data(data): return data
        default: return nil
        }
    }
}
