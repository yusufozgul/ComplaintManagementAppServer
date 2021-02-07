//
//  Notification.swift
//  
//
//  Created by Yusuf Özgül on 7.02.2021.
//

import Fluent
import Vapor

struct RecordAnswerRequestData: Content {
    var recordId: Int
    var answer: String
    var status: RecordStatus
}

extension RecordAnswerRequestData: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("answer", as: String.self, is: .count(10...))
        validations.add("status", as: String.self, is: !.empty)
        validations.add("recordId", as: Int.self, is: .valid)
    }
}

enum RecordStatus: String, Content {
    case pending
    case resolved
    case denied
    case delayed
}

final class Notification: Model, Content {
    struct Public: Content {
        let id: Int
        let record: Record.Public
        let date: Date?
        let result: String
    }
    
    static let schema = "notifications"
    
    @ID(custom: "id", generatedBy: .database)
    var id: Int?
    
    @Parent(key: "record_id")
    var record: Record
    
    @Field(key: "result")
    var result: String
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    init() {}
    
    init(id: Int? = nil, recordId: Record.IDValue, result: String) {
        self.id = id
        self.$record.id = recordId
        self.result = result
    }
}

extension Notification {
    func asPublic() throws -> Public {
        Public(id: try requireID(),
               record: try record.asPublic(),
               date: createdAt,
               result: result)
    }
}


