//
//  UserController.swift
//  
//
//  Created by Yusuf Özgül on 6.02.2021.
//

import Vapor
import Fluent

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let recordsRoute = routes.grouped("user")
        let tokenProtected = recordsRoute.grouped(Token.authenticator())
        
        tokenProtected.get("records", use: getRecords)
    }
    
    fileprivate func getRecords(req: Request) throws -> EventLoopFuture<[Record.Public]> {
        let user = try req.auth.require(User.self)
        
        return user.$records.query(on: req.db)
            .with(\.$user)
            .with(\.$location) {
                $0.with(\.$city)
            }
            .all()
            .flatMapThrowing({ records in
                records.compactMap({ try? $0.asPublic() })
            })
    }
}

