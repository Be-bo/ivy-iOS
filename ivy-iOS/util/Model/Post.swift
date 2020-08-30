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

class Post: Identifiable/*, Codable*/ {
    
    @DocumentID var id: String?
    var uni_domain: String = "" //cannot be null
    var author_id: String = "" //cannot be null
    var author_name: String = "" //cannot be null
    var author_is_organization: Bool = false //cannot be null
    var is_event = false //cannot be null
    var main_feed_visible = true
    var creation_millis: Int? = 0 //cannot be null
    var creation_platform = "iOS" //cannot be null
    var text = "" //cannot be null
    var visual = ""
    var pinned_id = ""
    var pinned_name = ""
    var views_id = [String]()
    
    
    func docToObject(doc: DocumentSnapshot){ //TODO: not ideal but good enough for now (use Codable when time available)
        id = doc.documentID
        if let uni = doc.get("uni_domain") as? String,
            let auth_id = doc.get("author_id") as? String,
            let auth_name = doc.get("author_name") as? String,
            let auth_is_org = doc.get("author_is_organization") as? Bool,
            let is_eve = doc.get("is_event") as? Bool,
            let crea_mil = doc.get("creation_millis") as? Int,
            let creat_plat = doc.get("creation_platform") as? String,
            let txt = doc.get("text") as? String{
            uni_domain = uni
            author_id = auth_id
            author_name = auth_name
            author_is_organization = auth_is_org
            is_event = is_eve
            creation_millis = crea_mil
            creation_platform = creat_plat
            text = txt
        }
        
        if let vis = doc.get("visual") as? String{
            visual = vis
        }
        
        if let pnd_id = doc.get("pinned_id") as? String{
            pinned_id = pnd_id
        }
        
        if let pnd_name = doc.get("pinned_name") as? String{
            pinned_name = pnd_name
        }
        
        if let views = doc.get("views_id") as? [String]{
            views_id = views
        }
    }
    
    
    // For convenience
    func addPin(id: String, name: String) {
        self.pinned_id = id
        self.pinned_name = name
    }
    
    func getMap() -> [String:Any]{
        var retVal = [String: Any]()
        retVal["id"] = id ?? ""
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
