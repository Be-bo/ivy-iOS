//
//  Comment.swift
//  ivy-iOS
//
//  Created by Robert on 2020-08-29.
//  Copyright © 2020 ivy. All rights reserved.
//


import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class Comment: Identifiable, Encodable/*, Codable*/ {
    
    var id: String? //cannot be null
    var author_id: String = "" //cannot be null
    var author_is_organization: Bool = true  //cannot be null
    var author_name: String = ""  //cannot be null
    var text: String = ""  //cannot be null, serves as visual if comment is image
    var type: Int = 1 //cannot be null
    var uni_domain: String = ""  //cannot be null
    var creation_millis: Int = 0 //cannot be null
    
    init() {}
    
    func docToObject(doc: DocumentSnapshot){
        id = doc.documentID
        if let author_i = doc.get("author_id") as? String,
            let author_is_org = doc.get("author_is_organization") as? Bool,
            let author_nam = doc.get("author_name") as? String,
            let txt = doc.get("text") as? String,
            let typ = doc.get("type") as? Int,
            let uni_dom = doc.get("uni_domain") as? String,
            let cre_mil = doc.get("creation_millis") as? Int{
            
            author_id = author_i
            author_is_organization = author_is_org
            author_name = author_nam
            text = txt
            type = typ
            uni_domain = uni_dom
            creation_millis = cre_mil
        }
    }
    
    func setInitialData(id: String, authorId: String, authorIsOrg: Bool, authorNam: String, txt: String, typ: Int, uniDom: String, creaMil: Int) {
        self.id = id
        self.author_id = authorId
        self.author_is_organization = authorIsOrg
        self.author_name = authorNam
        self.text = txt
        self.type = typ
        self.uni_domain = uniDom
        self.creation_millis = creaMil
    }
    
    func getMap() -> [String:Any] {
        var retVal = [String: Any]()
        retVal["id"] = id
        retVal["author_id"] = author_id
        retVal["author_is_organization"] = author_is_organization
        retVal["author_name"] = author_name
        retVal["text"] = text
        retVal["type"] = type
        retVal["uni_domain"] = uni_domain
        retVal["creation_millis"] = creation_millis
        return retVal
    }
}
