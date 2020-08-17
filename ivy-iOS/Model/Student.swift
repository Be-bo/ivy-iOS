//
//  Student.swift
//  ivy-iOS
//
//  Created by Zahra Ghavasieh on 2020-08-15.
//  Copyright © 2020 ivy. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class Student: User {
    
    var degree: String
    var birth_millis: Int = 0
    
    init(id: String, email: String, degree: String) {
        self.degree = degree
        super.init(id: id, email: email, is_organization: false, is_club: false)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}
