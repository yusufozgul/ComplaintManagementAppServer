import Vapor

struct ApiResponse<T: Content>: Content {
    let error: Bool
    let message: String
    let data: T?
    
    init(error: Bool, message: String, data: T? = nil) {
        self.error = error
        self.message = message
        self.data = data
    }
}

struct EmptyResponse: Content { }
