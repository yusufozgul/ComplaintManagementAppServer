//
//  CreateLocation.swift
//  
//
//  Created by Yusuf Özgül on 6.02.2021.
//

import Fluent
import Vapor

struct CreateLocation_City: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Location_City.schema)
            .field("id", .int, .identifier(auto: true))
            .field("city_name", .string, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Record.schema).delete()
    }
}

struct CreateLocation_District: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Location_District.schema)
            .field("id", .int, .identifier(auto: true))
            .field("city_id", .int, .references("location-city", "id"), .required)
            .field("district_name", .string, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Record.schema).delete()
    }
}
