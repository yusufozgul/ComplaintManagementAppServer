//
//  File.swift
//  
//
//  Created by Yusuf Özgül on 6.02.2021.
//

import Fluent
import Vapor

final class Location_City: Model, Content {
    struct Public: Content {
        let id: Int
        let cityName: String
    }
    
    static let schema = "location-city"
    
    @ID(custom: "id", generatedBy: .database)
    var id: Int?
    
    
    @Field(key: "city_name")
    var cityName: String
    
    @Children(for: \.$city)
    var districts: [Location_District]
    
    
    init() {}
    
    init(id: Int? = nil, cityName: String) {
        self.id = id
        self.cityName = cityName
    }
}

extension Location_City {
    func asPublic() throws -> Public {
        Public(id: try requireID(),
               cityName: cityName)
    }
}
