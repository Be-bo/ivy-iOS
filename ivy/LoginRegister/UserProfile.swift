//
//  RegisterInfoStruct.swift
//  ivy
//
//  Created by paul dan on 2019-06-30.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import Foundation

//global struct which will hold all the information required for a user to register
struct UserProfile {
    var email: String?
    
    init(email:String? = nil) {
        self.email = email
    }
}
