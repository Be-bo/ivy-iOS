//
//  Chatroom.swift
//  ivy
//
//  Created by Zahra Ghavasieh on 2020-12-10.
//  Copyright © 2020 ivy. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class Message: Identifiable, Codable, Equatable {
    
    // future TODO: Use DocumentID so we don't have to add id as a field on firestore
    // @DocumentID var doc_id: String?
    var id: String = ""
    var author: String = ""
    var text: String = ""
    var time_stamp: Int? = 0
    
    
    // Only for existring Messages
    init() {}
    
    
    // Use this for creating new Messages
    init(author: String, text: String) {
        self.id = UUID.init().uuidString
        self.author = author
        self.text = text
        self.time_stamp = Int(Utils.getCurrentTimeInMillis())
    }
    
    // isEqualTo function
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
    }
    
    // getPath
    static func messagesPath(chatroomID : String) -> String {
        return "conversations/\(chatroomID)/messages"
    }
}
