//
//  User.swift
//  
//
//  Created by Yusuf Özgül on 6.02.2021.
//

import Fluent
import Vapor

final class User: Model {
    struct Public: Content {
        let mail: String
        let id: Int
        let createdAt: Date?
        let updatedAt: Date?
        let userType: String
        let phone: String
        let name: String
        let surname: String
        let city: String
        let district: String
    }
    
    static let schema = "users"
    
    @ID(custom: "id", generatedBy: .database)
    var id: Int?
    
    @Field(key: "mail")
    var mail: String
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "surname")
    var surname: String
    
    @Parent(key: "location_id")
    var location: Location_District
    
    @Field(key: "accountType")
    var accountType: String
    
    @Field(key: "phone")
    var phone: String
    
    @Field(key: "password_hash")
    var passwordHash: String
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    
    @Children(for: \.$user)
    var records: [Record]
    
    init() {
    }
    
    init(id: Int? = nil, mail: String, passwordHash: String, name: String, surname: String, locationID: Int, accountType: String, phone: String) {
        self.id = id
        self.mail = mail
        self.passwordHash = passwordHash
        self.name = name
        self.surname = surname
        self.$location.id = locationID
        self.accountType = accountType
        self.phone = phone
    }
}

extension User {
    static func create(from userSignup: Signup) throws -> User {
        User(mail: userSignup.mail,
             passwordHash: try Bcrypt.hash(userSignup.password),
             name: userSignup.name,
             surname: userSignup.surname,
             locationID: userSignup.locationID,
             accountType: AccountType.user.rawValue,
             phone: userSignup.phone)
    }
    
    func createToken(source: SessionSource) throws -> Token {
        let calendar = Calendar(identifier: .gregorian)
        let expiryDate = calendar.date(byAdding: .year, value: 1, to: Date())
        return try Token(userId: requireID(),
                         token: [UInt8].random(count: 16).base64, source: source, expiresAt: expiryDate)
    }
    
    func asPublic() throws -> Public {
        Public(mail: mail,
               id: try requireID(),
               createdAt: createdAt,
               updatedAt: updatedAt,
               userType: accountType,
               phone: phone,
               name: name,
               surname: surname,
               city: location.city.cityName,
               district: location.districtName)
    }
}

extension User: ModelAuthenticatable {
    static let usernameKey = \User.$mail
    static let passwordHashKey = \User.$passwordHash
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.passwordHash)
    }
}
