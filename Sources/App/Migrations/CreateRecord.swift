//
//  CreateRecord.swift
//  
//
//  Created by Yusuf Özgül on 6.02.2021.
//

import Fluent
import Vapor

struct CreateRecords: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Record.schema)
            .field("id", .int, .identifier(auto: true))
            .field("user_id", .int, .references("users", "id"), .required)
            .field("created_at", .datetime, .required)
            .field("title", .string, .required)
            .field("body", .string, .required)
            .field("location_id", .int, .references("location-district", "id"), .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Record.schema).delete()
    }
}
