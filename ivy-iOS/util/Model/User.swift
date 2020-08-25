//
//  User.swift
//  ivy-iOS
//
//  Created by Zahra Ghavasieh on 2020-08-14.
//  Copyright © 2020 ivy. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class User: Identifiable, Encodable/*, Codable*/ {
    @DocumentID var id: String? //cannot be null
    var email: String = "" //cannot be null
    var name: String = "" //cannot be null
    var uni_domain: String = "" //cannot be null
    var registration_millis: Int = 0 //cannot be null
    var messaging_token: String = ""
    var is_organization: Bool = false //cannot be null
    var is_club: Bool = false
    var is_banned = false //cannot be null
    var registration_platform = "" //cannot be null
    var member_ids = [String]()
    var is_private = false //cannot be null
    var post_ids = [String]()
    var request_ids = [String]()
    var degree: String = ""
    var birth_millis: Int = 0
    
    
    func docToObject(doc: DocumentSnapshot){
        id = doc.documentID
        if let emai = doc.get("email") as? String,
            let nam = doc.get("name") as? String,
            let un_dom = doc.get("uni_domain") as? String,
            let reg_mil = doc.get("registration_millis") as? Int,
            let is_org = doc.get("is_organization") as? Bool,
            let is_bnd = doc.get("is_banned") as? Bool,
            let reg_plat = doc.get("registration_platform") as? String,
            let is_priv = doc.get("is_private") as? Bool{
            email = emai
            name = nam
            uni_domain = un_dom
            registration_millis = reg_mil
            is_organization = is_org
            is_banned = is_bnd
            registration_platform = reg_plat
            is_private = is_priv
        }
        
        if let msg_token = doc.get("messaging_token") as? String{
            messaging_token = msg_token
        }
        
        if let is_clb = doc.get("is_club") as? Bool{
            is_club = is_clb
        }
        
        if let members = doc.get("member_ids") as? [String]{
            member_ids = members
        }
        
        if let posts = doc.get("post_ids") as? [String]{
            post_ids = posts
        }
        
        if let requests = doc.get("request_ids") as? [String]{
            request_ids = requests
        }
        
        if let degr = doc.get("degree") as? String{
            degree = degr
        }
        
        if let birth_mil = doc.get("birth_millis") as? Int{
            birth_millis = birth_mil
        }
    }
    
    func profileImagePath() -> String {
        return "userfiles/\(self.id ?? "")/profileimage.jpg"
    }
    
    func previewImagePath() -> String {
        return "userfiles/\(self.id ?? "")/previewimage.jpg"
    }
}
