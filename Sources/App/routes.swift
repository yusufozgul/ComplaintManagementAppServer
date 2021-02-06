import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get("hello") { req -> String in
        return "Hello, world!"
    }

    try app.register(collection: AuthController())
    try app.register(collection: RecordController())
    try app.register(collection: UserController())
    try app.register(collection: LocationController())
}
