//
//  AuthController.swift
//  
//
//  Created by Yusuf Özgül on 6.02.2021.
//

import Fluent
import Vapor

struct NewSession: Content {
    let token: String
}

struct AuthController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let usersRoute = routes.grouped("users")
        usersRoute.post("signup", use: create)
        usersRoute.post("login", use: login)
        
        let tokenProtected = usersRoute.grouped(Token.authenticator())
        tokenProtected.get("me", use: getMyOwnUser)
        
//        let passwordProtected = usersRoute.grouped(User.authenticator())
//        passwordProtected.post("login", use: login)
    }
    
    fileprivate func login(req: Request) throws -> EventLoopFuture<NewSession> {
        let user = try req.auth.require(User.self)
        let token = try user.createToken(source: .login)
        
        return token.save(on: req.db).flatMapThrowing {
            NewSession(token: token.value)
        }
    }
    
    
    fileprivate func create(req: Request) throws -> EventLoopFuture<NewSession> {
        try Signup.validate(content: req)
        let userSignup = try req.content.decode(Signup.self)
        let user = try User.create(from: userSignup)
        var token: Token!
        
        return checkIfUserExists(userSignup.mail, req: req).flatMap { exists in
            guard !exists else {
                return req.eventLoop.future(error: Abort(.badRequest))
            }
            
            return user.save(on: req.db)
        }.flatMap {
            guard let newToken = try? user.createToken(source: .signup) else {
                return req.eventLoop.future(error: Abort(.internalServerError))
            }
            token = newToken
            return token.save(on: req.db)
        }.flatMapThrowing {
            NewSession(token: token.value)
        }
    }
    
    private func checkIfUserExists(_ email: String, req: Request) -> EventLoopFuture<Bool> {
        User.query(on: req.db)
            .filter(\.$mail == email)
            .first()
            .map { $0 != nil }
    }
    
    func getMyOwnUser(req: Request) throws -> User.Public {
        try req.auth.require(User.self).asPublic()
    }
}



