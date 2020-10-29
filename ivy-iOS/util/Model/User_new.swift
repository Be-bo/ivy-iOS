//
//  User.swift
//  ivy-iOS
//
//  Created by Zahra Ghavasieh on 2020-08-14.
//  Copyright © 2020 ivy. All rights reserved.
//
//  Meant to be used for both Student and Organization users
//  Contains their shared attributes
//  TODO: Eventually make into "User"
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class User_new: Identifiable, Codable {
    
    //@DocumentID var id: String?
    var id: String = ""
    var email: String = ""
    var name: String = ""
    var uni_domain: String = ""
    //@ServerTimestamp var registration_millis: Timestamp?    // Created automatically when uploaded to Firebase
    var registration_millis: Int = 0
    var messaging_token: String = ""
    var is_organization: Bool = false
    var is_club: Bool = false
    var is_banned = false
    var registration_platform = "iOS"
    
    // Currently unused
    var is_private = false
    var post_ids = [String]()
    
    // Organization
    var member_ids: [String]?
    var request_ids: [String]?
    
    // Student
    var degree: String?
    var birth_millis: Int?
    
    
    // Student
    init(id: String, email: String, degree: String) {
        self.degree = degree
        self.birth_millis = 0
        setInitialData(id: id, email: email, is_organization: false, is_club: false)
    }
    
    // Organization
    init(id: String, email: String, is_club: Bool) {
        self.member_ids = [String]()
        self.request_ids = [String]()
        setInitialData(id: id, email: email, is_organization: true, is_club: is_club)
    }
    
    // Only use in repo
    init() {}
    
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
    
    private func setInitialData(id: String, email: String, is_organization: Bool, is_club: Bool) {
        self.id = id
        self.email = email
        self.is_organization = is_organization
        self.is_club = is_club
        
        // Get Domain
        let splitEmail = email.split(separator: "@")
        if (splitEmail.count > 1) {
            self.uni_domain = String(splitEmail[1])
        }
        self.registration_millis = Int(Utils.getCurrentTimeInMillis())
        self.name = String(splitEmail[0])   // Set default name
    }
    
    func userPath() -> String {
        return "users/\(self.id)"
    }
    
    func profileImagePath() -> String {
        return "userfiles/\(self.id)/profileimage.jpg"
    }
    
    func previewImagePath() -> String {
        return "userfiles/\(self.id)/previewimage.jpg"
    }
}
