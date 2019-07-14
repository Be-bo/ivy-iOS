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
    var first: String?
    var last: String?
    var gender: String?
    var degree: String?

    
    init(email:String? = nil, first:String? = nil, last:String? = nil , gender:String? = nil, degree:String? = nil) {
        self.email = email;
        self.first = first;
        self.last = last;
        self.gender = gender;
        self.degree = degree;
    }
}
