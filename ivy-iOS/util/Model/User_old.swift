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

class User: Identifiable, Codable {
    
    @DocumentID var id: String?
    var email: String
    var name: String
    @ExplicitNull var uni_domain: String? = nil
    @ServerTimestamp var registration_millis: Timestamp?    // Created automatically when uploaded to Firebase
    @ExplicitNull var messaging_token: String? = nil
    var is_organization: Bool
    var is_club: Bool
    var is_banned = false
    let registration_platform = "iOS"
    
    
    init(id: String, email: String, is_organization: Bool, is_club: Bool) {
        self.id = id
        self.email = email
        self.is_organization = is_organization
        self.is_club = is_club
        
        // Get Domain
        let splitEmail = email.split(separator: "@")
        if (splitEmail.count > 1) {
            self.uni_domain = String(splitEmail[1])
        }
        self.name = String(splitEmail[0])   // Set default name
    }
    
    func userPath() -> String {
        return "users/\(self.id ?? "")"
    }
}
