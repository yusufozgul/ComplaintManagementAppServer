//
//  CreateTokens.swift
//
//
//  Created by Yusuf Özgül on 6.02.2021.
//

import Fluent

struct CreateTokens: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Token.schema)
            .field("id", .int, .identifier(auto: true))
            .field("user_id", .int, .references("users", "id"))
            .field("value", .string, .required)
            .unique(on: "value")
            .field("source", .int, .required)
            .field("created_at", .datetime, .required)
            .field("expires_at", .datetime)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Token.schema).delete()
    }
}

