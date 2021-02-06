//
//  Location-District.swift
//  
//
//  Created by Yusuf Özgül on 6.02.2021.
//

import Fluent
import Vapor

final class Location_District: Model, Content {
    struct Public: Content {
        let id: Int
        let districtName: String
    }
    
    static let schema = "location-district"
    
    @ID(custom: "id", generatedBy: .database)
    var id: Int?
    
    
    @Field(key: "district_name")
    var districtName: String
    
    @Parent(key: "city_id")
    var city: Location_City
    
    @Children(for: \.$location)
    var records: [Record]
    
    @Children(for: \.$location)
    var users: [User]
    
    init() {}
    
    init(id: Int? = nil, districtName: String, cityId: Int) {
        self.id = id
        self.districtName = districtName
        self.$city.id = cityId
    }
}

extension Location_District {
    func asPublic() throws -> Public {
        Public(id: try requireID(),
               districtName: districtName)
    }
}

