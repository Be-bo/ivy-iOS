//
//  Conversation.swift
//  ivy-iOS
//
//  Created by paul dan on 2020-01-07.
//  Copyright © 2020 ivy social network. All rights reserved.
//
//represents each individual conversaiton this user has going, whether its a group chat or not

import Foundation



struct Conversation {
    var users: [String]
    var dictionary: [String: Any] {
        return ["users": users]
    }
}



extension Conversation {
    init?(dictionary: [String:Any]) {
        guard let chatUsers = dictionary["users"] as? [String] else {return nil}    //add a gaurd to make sure not nil
        self.init(users: chatUsers) // init the class with users
    }
}
