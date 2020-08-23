//
//  post.swift
//  ivy-iOS
//
//  Created by Zahra Ghavasieh on 2020-08-21.
//  Copyright © 2020 ivy. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class Event: Identifiable/*, Codable*/ {
    @DocumentID var id: String? //cannot be null
    var name: String = "" //cannot be null
    var is_event = true //cannot be null
    var uni_domain: String = "" //cannot be null
    var author_id: String = "" //cannot be null
    var author_name: String = "" //cannot be null
    var author_is_organization: Bool = false //cannot be null
    var main_feed_visible = true
    var creation_millis = 0 //cannot be null
    var creation_platform = "iOS" //cannot be null
    var text = "" //cannot be null
    var visual = ""
    var views_id = [String]()
    var start_millis: Int = 0 //cannot be null
    var end_millis: Int = 0 //cannot be null
    var going_ids = [String]()
    var is_active = true //cannot be null
    var is_featured = false //cannot be null
    var link: String = ""
    var location: String = "" //cannot be null
    
    
    func docToObject(doc: DocumentSnapshot){ // TODO: not ideal for now but had problems with the codable
        id = doc.documentID
        if let nam = doc.get("name") as? String,
            let is_ev = doc.get("is_event") as? Bool,
            let uni_dom = doc.get("uni_domain") as? String,
            let au_id = doc.get("author_id") as? String,
            let au_nam = doc.get("author_name") as? String,
            let au_org = doc.get("author_is_organization") as? Bool,
            let crea_mill = doc.get("creation_millis") as? Int,
            let crea_plat = doc.get("creation_platform") as? String,
            let txt = doc.get("text") as? String,
            let loc = doc.get("location") as? String,
            let start_mil = doc.get("start_millis") as? Int,
            let end_mil = doc.get("end_millis") as? Int,
            let is_act = doc.get("is_active") as? Bool,
            let is_feat = doc.get("is_featured") as? Bool{
            name = nam
            is_event = is_ev
            uni_domain = uni_dom
            author_id = au_id
            author_name = au_nam
            author_is_organization = au_org
            creation_millis = crea_mill
            creation_platform = crea_plat
            text = txt
            location = loc
            start_millis = start_mil
            end_millis = end_mil
            is_active = is_act
            is_featured = is_feat
        }
        
        if let vis = doc.get("visual") as? String{
            visual = vis
        }
        
        if let going_is = doc.get("going_ids") as? [String]{
            going_ids = going_is
        }
        
        if let views_is = doc.get("views_id") as? [String]{
            views_id = views_is
        }
        
        if let lin = doc.get("link") as? String{
            link = lin
        }
    }
}
