//
//  RecordController.swift
//  
//
//  Created by Yusuf Özgül on 6.02.2021.
//

import Vapor
import Fluent

struct RecordController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let recordsRoute = routes.grouped("record")
        let tokenProtected = recordsRoute.grouped(Token.authenticator())
        
        tokenProtected.get("all", use: getAllRecord)
        tokenProtected.get("allFiltered", use: getAllRecordFiltered)
        tokenProtected.get(":recordId", use: getRecord)
        tokenProtected.post("new", use: create)
    }
    
    fileprivate func create(req: Request) throws -> EventLoopFuture<ApiResponse<EmptyResponse>> {
        let user = try req.auth.require(User.self)
        try RecordRequestData.validate(content: req)
        let data = try req.content.decode(RecordRequestData.self)
        let record = Record(userId: try user.requireID(), title: data.title, body: data.body, locationID: user.$location.id)
        
        return user.$records.create(record, on: req.db).map { _ in
            return .init(error: false, message: "Ok")
        }
    }
    
    fileprivate func getRecord(req: Request) throws -> EventLoopFuture<Record.Public> {
        guard let recordId = req.parameters.get("recordId", as: Int.self) else {
            throw Abort(.badRequest)
        }
        
        return Record.query(on: req.db)
            .filter(\.$id == recordId)
            .with(\.$user) {
                $0.with(\.$location) {
                    $0.with(\.$city)
                }
            }
            .with(\.$location) {
                $0.with(\.$city)
            }
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMapThrowing { try $0.asPublic() }
    }
    
    fileprivate func getAllRecord(req: Request) throws -> EventLoopFuture<[Record.Public]> {
        return Record.query(on: req.db)
            .with(\.$user) {
                $0.with(\.$location) {
                    $0.with(\.$city)
                }
            }
            .with(\.$location) {
                $0.with(\.$city)
            }
            .all()
            .map({ records in
                records.compactMap({ try? $0.asPublic() })
            })
    }
    
    fileprivate func getAllRecordFiltered(req: Request) throws -> EventLoopFuture<[Record.Public]> {
        let user = try req.auth.require(User.self)
        
        return Record.query(on: req.db)
            .with(\.$user) {
                $0.with(\.$location) {
                    $0.with(\.$city)
                }
            }
            .with(\.$location) {
                $0.with(\.$city)
            }
            .all()
            .map({ records in
                let filteredRecords = records.filter({ $0.$location.id == user.$location.id })
                return filteredRecords.compactMap({ try? $0.asPublic() })
            })
    }
}
