//
//  Post_new.swift
//  ivy
//
//  Created by Zahra Ghavasieh on 2020-10-22.
//  Copyright © 2020 ivy. All rights reserved.
//
//  Basic Codable class for Posts
//  Built for Firebase
//  Parent of Event class
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class Post_new: Identifiable, Codable {
    
    // Use DocumentID so we don't have to add id as a field on firestore
    // @DocumentID var doc_id: String?
    var id: String
    var uni_domain: String = ""
    var author_id: String = ""
    var author_name: String = ""
    var author_is_organization: Bool = false
    var is_event = false
    var main_feed_visible = true
    var creation_millis: Int? = 0
    var creation_platform = "iOS"
    var text = ""
    var visual = ""
    var pinned_id = ""
    var pinned_name = ""
    var views_id = [String]()
    
    
    // Convenience Method to convert to old version of Post
    // TODO: delete later
    func convertNewToOld() -> Post {
        let post = Post()
        
        post.id = id
        post.uni_domain = uni_domain
        post.author_id = author_id
        post.author_name = author_name
        post.author_is_organization = author_is_organization
        post.is_event = is_event
        post.creation_millis = creation_millis
        post.creation_platform = creation_platform
        post.text = text
        post.visual = visual
        post.pinned_id = pinned_id
        post.pinned_name = pinned_name
        post.views_id = views_id
        
        return post
    }
    
    
    // For convenience
    func addPin(id: String, name: String) {
        self.pinned_id = id
        self.pinned_name = name
    }
    
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
        retVal["pinned_id"] = pinned_id
        retVal["pinned_name"] = pinned_name
        retVal["views_id"] = views_id
        return retVal
    }
}
