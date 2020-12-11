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

class Chatroom: Identifiable, Equatable, Codable {
    
    
    // future TODO: Use DocumentID so we don't have to add id as a field on firestore
    // @DocumentID var doc_id: String?
    var id: String = ""
    var members = [String]()
    
    
    // Only for existring Chatrooms
    init() {}
    
    
    // Use this for new chatrooms
    init(members: [String]) {
        self.id = UUID.init().uuidString
        self.members = members
    }
    
    // Convenience init
    convenience init(id1: String, id2: String) {
        self.init(members: [id1, id2])
    }
    
    
    // isEqualTo function
    static func == (lhs: Chatroom, rhs: Chatroom) -> Bool {
        return lhs.id == rhs.id
    }
    
    
    
    // MARK: PATHs
    func getPath() -> String {
        return "conversations/\(id)"
    }
    
    static func chatroomPath(_ id: String) -> String {
        return "conversations/\(id)"
    }
    
}
