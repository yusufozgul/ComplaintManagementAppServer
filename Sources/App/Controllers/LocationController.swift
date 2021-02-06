//
//  LocationController.swift
//  
//
//  Created by Yusuf Özgül on 6.02.2021.
//

import Vapor
import Fluent

struct LocationController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let recordsRoute = routes.grouped("location")
        
        recordsRoute.get("cityList", use: getCityList)
        recordsRoute.get(":cityId", use: getDistrictList)
    }
    
    fileprivate func getDistrictList(req: Request) throws -> EventLoopFuture<[Location_District.Public]> {
        guard let id = req.parameters.get("cityId", as: Int.self) else {
            throw Abort(.badRequest)
        }
        
        return Location_District.query(on: req.db)
            .with(\.$city)
            .filter( \.$city.$id == id)
            .all()
            .flatMapThrowing({ district in
                var districtList = district.compactMap({ try? $0.asPublic() })
                districtList.sort(by: { $0.districtName < $1.districtName})
                return districtList
            })
    }
    
    fileprivate func getCityList(req: Request) throws -> EventLoopFuture<[Location_City.Public]> {
        return Location_City.query(on: req.db)
            .all()
            .map({ city in
                var cityList = city.compactMap({ try? $0.asPublic() })
                cityList.sort(by: { $0.cityName < $1.cityName})
                return cityList
            })
    }
}

