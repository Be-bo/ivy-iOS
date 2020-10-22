//
//  Organization.swift
//  ivy-iOS
//
//  Created by Zahra Ghavasieh on 2020-08-15.
//  Copyright © 2020 ivy. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class Organization: User_new {
    
    var member_ids = [String]()
    var request_ids = [String]()
    
    init(id: String, email: String, is_club: Bool) {
        super.init(id: id, email: email, is_organization: true, is_club: is_club)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}
