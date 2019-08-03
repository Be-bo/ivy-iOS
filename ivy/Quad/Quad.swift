//
//  Quad.swift
//  ivy
//
//  Created by Robert on 2019-07-28.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import UIKit

class Quad: UIViewController {
    
    private var thisUserProfile = Dictionary<String, Any>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func updateProfile(updatedProfile: Dictionary<String, Any>){
        thisUserProfile = updatedProfile
        print("updated profile")
    }
}
