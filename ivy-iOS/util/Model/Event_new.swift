//
//  Event_new.swift
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

class Event_new: Identifiable, Codable{
    
    @DocumentID var doc_id: String?
    var id: String = ""
    var name: String = ""
    var is_event = true
    var uni_domain: String = ""
    var author_id: String = ""
    var author_name: String = "Author"
    var author_is_organization: Bool = false
    var main_feed_visible = true
    var creation_millis = 0
    var creation_platform = "iOS"
    var text = "Event Text"
    var visual = ""
    var views_id = [String]()
    var start_millis: Int = 0
    var end_millis: Int = 0
    var going_ids = [String]()
    var is_active = true
    var is_featured = false
    var link: String = ""
    var location: String = "Main Campus"    
    
    
    // Only for existing posts
    init() {}
    
    
    // Use this for creating new posts
    init(uni: String, name: String, text: String, link: String, location: String) {
        self.id = UUID.init().uuidString
        self.uni_domain = uni
        self.creation_millis = Int(Utils.getCurrentTimeInMillis())
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
        return "universities/\(Utils.getCampusUni())/posts/\(self.id)"
    }
    
    static func eventPath(id: String) -> String{
        return "universities/\(Utils.getCampusUni())/posts/\(id)"
    }
    
    
    // Convenience Method to convert to old version of event
    // TODO: delete later
    func convertNewToOld() -> Event {
        let event = Event()
        
        event.id = id
        event.name = name
        event.is_event = is_event
        event.uni_domain = uni_domain
        event.author_id = author_id
        event.author_name = author_name
        event.author_is_organization = author_is_organization
        event.creation_millis = creation_millis
        event.creation_platform = creation_platform
        event.text = text
        event.location = location
        event.start_millis = start_millis
        event.end_millis = end_millis
        event.is_active = is_active
        event.is_featured = is_featured
        event.visual = visual
        event.going_ids = going_ids
        event.views_id = views_id
        event.link = link
        
        return event
    }
    
    // Maybe delete later?
    func getMap() -> [String:Any]{
        var retVal = [String: Any]()
        retVal["id"] = id
        retVal["uni_domain"] = uni_domain
        retVal["author_id"] = author_id
        retVal["author_name"] = author_name
        retVal["author_is_organization"] = author_is_organization
        retVal["is_event"] = is_event
        retVal["main_feed_visible"] = main_feed_visible
        retVal["creation_millis"] = creation_millis
        retVal["creation_platform"] = creation_platform
        retVal["text"] = text
        retVal["visual"] = visual
        retVal["start_millis"] = start_millis
        retVal["end_millis"] = end_millis
        retVal["views_id"] = views_id
        retVal["going_ids"] = going_ids
        retVal["location"] = location
        retVal["link"] = link
        retVal["is_featured"] = is_featured
        retVal["is_active"] = is_active
        retVal["name"] = name
        return retVal
    }
}
