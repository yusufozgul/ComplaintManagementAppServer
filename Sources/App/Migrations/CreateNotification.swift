//
//  CreateNotification.swift
//  
//
//  Created by Yusuf Özgül on 7.02.2021.
//

import Fluent
import Vapor

struct CreateNotification: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Notification.schema)
            .field("id", .int, .identifier(auto: true))
            .field("record_id", .int, .references("records", "id"), .required)
            .field("created_at", .datetime, .required)
            .field("result", .string, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Notification.schema).delete()
    }
}
