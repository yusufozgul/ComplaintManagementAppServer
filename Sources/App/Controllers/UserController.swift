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
        
        let answerRoute = tokenProtected.grouped("answer")
        answerRoute.get(":recordId", use: getRecordAnswer)
    }
    
    fileprivate func getRecords(req: Request) throws -> EventLoopFuture<[Record.Public]> {
        let user = try req.auth.require(User.self)
        
        return user.$records.query(on: req.db)
            .with(\.$user) {
                $0.with(\.$location) {
                    $0.with(\.$city)
                }
            }
            .with(\.$location) {
                $0.with(\.$city)
            }
            .all()
            .flatMapThrowing({ records in
                records.compactMap({ try? $0.asPublic() })
            })
    }
    
    fileprivate func getRecordAnswer(req: Request) throws -> EventLoopFuture<Notification.Public> {
        guard let recordId = req.parameters.get("recordId", as: Int.self) else {
            throw Abort(.badRequest)
        }
        let user = try req.auth.require(User.self)
        
        return Notification.query(on: req.db)
            .with(\.$record) {
                $0.with(\.$user) {
                    $0.with(\.$location) {
                        $0.with(\.$city)
                    }
                }
                $0.with(\.$location) {
                    $0.with(\.$city)
                }
            }
            .filter(\.$record.$id == recordId)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMapThrowing {
                guard $0.record.$user.id == user.id ?? 0 else { throw Abort(.notFound) }
                return try $0.asPublic()
            }
    }
}

