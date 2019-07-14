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
    var birthday: String?
    var bio: String?
    var interests: Array<String>?

    
    init(email:String? = nil, first:String? = nil, last:String? = nil , gender:String? = nil, degree:String? = nil, birthday:String? = nil, bio:String?=nil, interests:Array<String>?=nil) {
        self.email = email;
        self.first = first;
        self.last = last;
        self.gender = gender;
        self.degree = degree;
        self.birthday = birthday;
        self.bio = bio;
        self.interests = interests;
        
    }
}
