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
    var id: String = ""
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
    
    
    // Only for existing posts
    init() {}
    
    
    // Use this for creating new posts
    init(uni: String, text: String) {
        self.id = UUID.init().uuidString
        self.uni_domain = uni
        self.creation_millis = Int(Utils.getCurrentTimeInMillis())
        self.text = text
    }
    
    
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
    
    
    // Convenience Functions
    func setAuthor(id: String, name: String, is_org: Bool) {
        self.author_id = id
        self.author_name = name
        self.author_is_organization = is_org
    }
    
    
    func addPin(id: String, name: String) {
        self.pinned_id = id
        self.pinned_name = name
    }
    
    
    // MARK: PATHs
    func getPostPath() -> String{
        return "universities/\(Utils.getCampusUni())/posts/\(self.id)" 
    }
}
