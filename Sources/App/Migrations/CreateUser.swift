//
//  File.swift
//  
//
//  Created by Yusuf Özgül on 6.02.2021.
//

import Fluent

struct CreateUsers: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(User.schema)
            .field("id", .int, .identifier(auto: true))
            .field("mail", .string, .required)
            .unique(on: "mail")
            .field("password_hash", .string, .required)
            .field("name", .string, .required)
            .field("surname", .string, .required)
            .field("districtID", .string, .required)
            .field("accountType", .string, .required)
            .field("phone", .string, .required)
            .unique(on: "phone")
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(User.schema).delete()
    }
}
