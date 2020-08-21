//
//  Post.swift
//  ivy-iOS
//
//  Created by Zahra Ghavasieh on 2020-08-20.
//  Copyright © 2020 ivy. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class Post: Identifiable, Codable {
    
    @DocumentID var id: String?
    var uni_domain: String
    var author_id: String
    var author_name: String
    var author_is_organization: Bool
    var is_event = false
    var main_feed_visible = true
    @ServerTimestamp var creation_millis: Timestamp?    // Created automatically when uploaded to Firebase
    let creation_platform = "iOS"
    var text = ""
    var visual = ""
    var pinned_id = ""
    var pinned_name = ""
    var views_id = [String]()
    
 
/* Initialization Methods */
    
    init(id: String?, uni_domain: String, author_id: String, author_name: String, author_is_organization: Bool, main_feed_visible: Bool) {
        self.id = id
        self.uni_domain = uni_domain
        self.author_id = author_id
        self.author_name = author_name
        self.author_is_organization = author_is_organization
        self.main_feed_visible = main_feed_visible
    }
    
    convenience init(event: Event) {
        self.init(
            id: event.id,
            uni_domain: event.uni_domain,
            author_id: event.author_id,
            author_name: event.author_name,
            author_is_organization: event.author_is_organization,
            main_feed_visible: event.main_feed_visible)
    }
    
    // For convenience
    func addPin(id: String, name: String) {
        self.pinned_id = id
        self.pinned_name = name
    }
    
    
/* Firebase & Storage Paths */

    func postPath() -> String {
        return "universities/\(uni_domain)/posts/\(self.id ?? "")"
    }
    
    func postFullVisualPath() -> String {
        return "postfiles/\(self.id ?? "")/\(self.id ?? "").jpg"
    }
    
    func postPreviewImagePath() -> String {
        return "postfiles/\(self.id ?? "")/previewimage.jpg"
    }
    
    func postCommentsPath(commentID: String = "") -> String {
        return postPath() + "/comments/" + commentID
    }
}
