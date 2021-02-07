//
//  DasboardController.swift
//  
//
//  Created by Yusuf Özgül on 7.02.2021.
//

import Vapor
import Fluent

struct DasboardController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let recordsRoute = routes.grouped("dashboard")
        let tokenProtected = recordsRoute.grouped(Token.authenticator())
        tokenProtected.get("details", use: getRecords)
        
        tokenProtected.grouped("filterType").get(":type", use: filterType)
        tokenProtected.grouped("filterDomain").get(":domain", use: filterDomain)
        tokenProtected.grouped("filterStatus").get(":status", use: filterStatus)
    }
    
    fileprivate func getRecords(req: Request) throws -> EventLoopFuture<DashboardResponse> {
        let user = try req.auth.require(User.self)
        guard user.accountType == AccountType.manager.rawValue else { throw Abort(.forbidden) }
        
        return Record.query(on: req.db)
            .all()
            .map {
                DashboardResponse(wishCount: $0.filter({ $0.recordType == RecordRequestData.RecordType.wish.rawValue }).count,
                                  complaintCount: $0.filter({ $0.recordType == RecordRequestData.RecordType.complaint.rawValue }).count,
                                  elektrikCount: $0.filter({ $0.domain == RecordRequestData.Domain.elektrik.rawValue }).count,
                                  parkVeBahcelerCount: $0.filter({ $0.domain == RecordRequestData.Domain.parkVeBahceler.rawValue }).count,
                                  ulasimCount: $0.filter({ $0.domain == RecordRequestData.Domain.ulasim.rawValue }).count,
                                  temizlikCount: $0.filter({ $0.domain == RecordRequestData.Domain.temizlik.rawValue }).count,
                                  altyapiCount: $0.filter({ $0.domain == RecordRequestData.Domain.altyapi.rawValue }).count,
                                  pendingCount: $0.filter({ $0.status == RecordStatus.pending.rawValue }).count,
                                  resolvedCount: $0.filter({ $0.status == RecordStatus.resolved.rawValue }).count,
                                  deniedCount: $0.filter({ $0.status == RecordStatus.denied.rawValue }).count,
                                  delayedCount: $0.filter({ $0.status == RecordStatus.delayed.rawValue }).count)
            }
    }
    
    fileprivate func filterType(req: Request) throws -> EventLoopFuture<[Record.Public]> {
        let user = try req.auth.require(User.self)
        guard user.accountType == AccountType.manager.rawValue else { throw Abort(.forbidden) }
        guard let recordType = req.parameters.get("type", as: String.self) else {
            throw Abort(.badRequest)
        }
        
        return Record.query(on: req.db)
            .with(\.$location) {
                $0.with(\.$city)
            }
            .with(\.$user) {
                $0.with(\.$location) {
                    $0.with(\.$city)
                }
            }
            .all()
            .flatMapThrowing {
                return try $0.filter({ $0.recordType == recordType}).map {
                    try $0.asPublic()
                }            }
    }
    
    fileprivate func filterDomain(req: Request) throws -> EventLoopFuture<[Record.Public]> {
        let user = try req.auth.require(User.self)
        guard user.accountType == AccountType.manager.rawValue else { throw Abort(.forbidden) }
        guard let domain = req.parameters.get("domain", as: String.self) else {
            throw Abort(.badRequest)
        }
        
        return Record.query(on: req.db)
            .with(\.$location) {
                $0.with(\.$city)
            }
            .with(\.$user) {
                $0.with(\.$location) {
                    $0.with(\.$city)
                }
            }
            .all()
            .flatMapThrowing {
                return try $0.filter({ $0.domain == domain }).map {
                    try $0.asPublic()
                }
            }
    }
    
    fileprivate func filterStatus(req: Request) throws -> EventLoopFuture<[Record.Public]> {
        let user = try req.auth.require(User.self)
        guard user.accountType == AccountType.manager.rawValue else { throw Abort(.forbidden) }
        guard let status = req.parameters.get("status", as: String.self) else {
            throw Abort(.badRequest)
        }
        
        return Record.query(on: req.db)
            .with(\.$location) {
                $0.with(\.$city)
            }
            .with(\.$user) {
                $0.with(\.$location) {
                    $0.with(\.$city)
                }
            }
            .all()
            .flatMapThrowing {
                return try $0.filter({ $0.status == status }).map {
                    try $0.asPublic()
                }
            }
    }
}

struct DashboardResponse: Content {
    let wishCount: Int
    let complaintCount: Int
    let elektrikCount: Int
    let parkVeBahcelerCount: Int
    let ulasimCount: Int
    let temizlikCount: Int
    let altyapiCount: Int
    let pendingCount: Int
    let resolvedCount: Int
    let deniedCount: Int
    let delayedCount: Int
    
}
