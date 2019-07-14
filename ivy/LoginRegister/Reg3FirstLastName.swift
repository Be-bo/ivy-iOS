//
//  Reg3FirstLastName.swift
//  ivy
//
//  Created by paul dan on 2019-07-13.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseCore
import FirebaseFirestore

class Reg3FirstLastName: UIViewController {

    
    var thirdStruct = UserProfile(email:"", first: "", last: "") //initializer which will be overidden by the email actually passed in

    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("third struct u dirty nigg", thirdStruct.email, thirdStruct.first, thirdStruct.last)
        
    }
    
}
