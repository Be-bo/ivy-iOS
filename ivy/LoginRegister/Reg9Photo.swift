//
//  Reg9Photo.swift
//  ivy
//
//  Created by paul dan on 2019-07-14.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseCore
import FirebaseFirestore

class Reg9Photo: UIViewController {

    //initializers
    var registerInfoStruct = UserProfile(email: "", first: "", last: "", gender: "", degree: "", birthday: "", bio:"", interests: [""]) //will be overidden by the actual data

    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("photo", registerInfoStruct)
    }
    
}
