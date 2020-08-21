//
//  Event.swift
//  ivy-iOS
//
//  Created by Zahra Ghavasieh on 2020-08-21.
//  Copyright © 2020 ivy. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class Event: Post {
    
    @ExplicitNull var start_millis: Int? = nil
    @ExplicitNull var end_millis: Int? = nil
    var going_ids = [String]()
    var is_active = true
    var is_featured = false
    @ExplicitNull var link: String? = nil
    @ExplicitNull var location: String? = nil
    @ExplicitNull var name: String? = nil
   
    
/* Initialization Methods */

    
    init(post: Post) {
        super.init(
            id: post.id,
            uni_domain: post.uni_domain,
            author_id: post.author_id,
            author_name: post.author_name,
            author_is_organization: post.author_is_organization,
            main_feed_visible: post.main_feed_visible
        )
        self.is_event = true
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    // For convenience
    func addSchedule(start: Int, end: Int) {
        self.start_millis = start
        self.end_millis = end
    }
}
