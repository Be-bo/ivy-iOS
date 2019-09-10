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
    var age:Int64? //age
    var banned: Bool?   //whether they're banned or not
    var bio: String?
    var birth_time:Int64?
    var degree: String?
    var email: String?
    var first_name: String?
    var gender: String?
    var id:String?
    var interests: Array<String>?
    var last_name: String?
    var last_post_id:String?  //last time they masde a post
    var picture_references: Array<String>?   //array containing the 5 different images a user can have uploaded to ivy
    var profile_hidden: Bool?    //from settings if user doesn't wanna be seen by anyone except for their friends
    var profile_picture: String? //path containing the storage reference to the useres profile picture
    var registration_millis : Int64?    //time they registered at in milliseconds
    var uni_domain : String?    //ex:@ucalgary.ca
    
    
    init(age:Int64?=nil, banned:Bool?=nil, bio:String?=nil,birth_time:Int64?=nil, degree:String? = nil, email:String? = nil, first_name:String? = nil, gender:String? = nil, id:String?=nil, interests:Array<String>?=nil, last_name:String? = nil , last_post_id:String?=nil, picture_references:Array<String>?=nil, profile_hidden:Bool?=nil , profile_picture:String?=nil, registration_millis:Int64?=nil, uni_domain:String?=nil) {
        
        self.age = age;
        self.banned = banned;
        self.bio = bio;
        self.birth_time = birth_time;
        self.degree = degree;
        self.email = email;
        self.first_name = first_name;
        self.gender = gender;
        self.id = id;
        self.interests = interests;
        self.last_name = last_name;
        self.last_post_id = last_post_id;
        self.picture_references = picture_references;
        self.profile_hidden = profile_hidden;
        self.profile_picture = profile_picture;
        self.registration_millis = registration_millis;
        self.uni_domain = uni_domain
    }
    
    //for returning a dictionary to allow me to push to firestore in Reg10
    var dictionary: [String: Any] {
        return ["age": age,
                "banned": banned,
                "bio": bio,
                "birth_time":birth_time,
                "degree":degree,
                "email":email,
                "first_name":first_name,
                "gender":gender,
                "id":id,
                "interests":interests,
                "last_name":last_name,
                "last_post_id":last_post_id,
                "picture_references":picture_references,
                "profile_hidden":profile_hidden,
                "profile_picture":profile_picture,
                "registration_millis":registration_millis,
                "uni_domain":uni_domain]
    }
    var nsDictionary: NSDictionary {
        return dictionary as NSDictionary
    }
    
}
