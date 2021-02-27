//
//  Event.swift
//  ivy
//
//  Created by Zahra Ghavasieh on 2020-10-22.
//  Copyright © 2020 ivy. All rights reserved.
//
//  Basic Codable class for events
//  Built for Firebase
//  Parent of Event class
//


import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class Event: Identifiable, Codable{
    
    // Use DocumentID so we don't have to add id as a field on firestore
    //@DocumentID var doc_id: String?
    var id: String = ""
    var name: String = ""
    var is_event = true
    var uni_domain: String = ""
    var author_id: String = ""
    var author_name: String = "Author"
    var author_is_organization: Bool = false
    var main_feed_visible = true
    var creation_millis: Int? = 0
    var creation_platform = "iOS"
    var text = "Event Text"
    var visual = ""
    var views_id = [String]()
    
    var start_millis: Int = 0
    var end_millis: Int = 0
    var going_ids = [String]()
    var is_active = true
    var is_featured = false
    var link: String?
    var location: String? = "Main Campus"    
    
    
    // Only for existing posts
    init() {}
    
    
    // Use this for creating new posts
    init(uni: String, name: String, text: String, link: String, location: String) {
        self.id = UUID.init().uuidString
        self.creation_millis = Int(Utils.getCurrentTimeInMillis())
        self.uni_domain = uni
        self.name = name
        self.text = text
        self.link = link
        self.location = location
    }
    
    
    // Convenience Functions
    func setAuthor(id: String, name: String, is_org: Bool) {
        self.author_id = id
        self.author_name = name
        self.author_is_organization = is_org
    }
    
    func setDates(start: Date, end: Date) {
        self.start_millis = Int(start.timeIntervalSince1970) * 1000
        self.end_millis = Int(end.timeIntervalSince1970) * 1000
    }
    
    
    // MARK: PATHs
    func getEventPath() -> String{
        if (uni_domain == "") {
            return "universities/\(Utils.getCampusUni())/posts/\(self.id)"
        }
        return "universities/\(uni_domain)/posts/\(self.id)"
    }
    
    static func eventPath(_ id: String) -> String{
        return "universities/\(Utils.getCampusUni())/posts/\(id)"
    }
}
