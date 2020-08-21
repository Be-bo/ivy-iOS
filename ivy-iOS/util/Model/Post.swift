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
    var author_is_organization = false
    var is_event = false
    var main_feed_visible = true
    @ServerTimestamp var creation_millis: Timestamp?
}
