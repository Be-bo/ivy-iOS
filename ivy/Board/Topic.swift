//
//  Topic.swift
//  ivy-iOS
//
//  Created by paul dan on 2020-03-03.
//  Copyright © 2020 ivy social network. All rights reserved.
//
//This class represents each topic under "all" from the topics collection


import Foundation

class Topic {
    var id = ""
    var name = ""
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
    
    public func getID() -> String{
        return id
    }
    
    public func setID(id:String){
        self.id = id
    }
    
    public func getName() -> String{
        return name
    }
    
    public func setName(name:String){
        self.name = name
    }
    
}
