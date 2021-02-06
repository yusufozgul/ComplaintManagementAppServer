//
//  Record.swift
//  
//
//  Created by Yusuf Özgül on 6.02.2021.
//

import Fluent
import Vapor

struct RecordRequestData: Content {
    var title: String
    var body: String
}

extension RecordRequestData: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("title", as: String.self, is: .count(10...))
        validations.add("body", as: String.self, is: .count(20...))
    }
}

final class Record: Model, Content {
    struct Public: Content {
        let id: Int
        let reporter: User.Public
        let date: Date?
        let title: String
        let body: String
        let city: String
        let district: String
    }
    
    static let schema = "records"
    
    @ID(custom: "id", generatedBy: .database)
    var id: Int?
    
    @Parent(key: "user_id")
    var user: User
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "body")
    var body: String
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Parent(key: "location_id")
    var location: Location_District
    
    init() {}
    
    init(id: Int? = nil, userId: User.IDValue, title: String,  body: String, locationID: Location_District.IDValue) {
        self.id = id
        self.$user.id = userId
        self.title = title
        self.body = body
        self.$location.id = locationID
    }
}

extension Record {
    func asPublic() throws -> Public {
        Public(id: try requireID(),
               reporter: try user.asPublic(),
               date: createdAt,
               title: title,
               body: body,
               city: location.city.cityName,
               district: location.districtName)
    }
}

