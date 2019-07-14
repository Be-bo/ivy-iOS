//
//  Reg6Birthday.swift
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

class Reg6Birthday: UIViewController {

    var registerInfoStruct = UserProfile(email: "", first: "", last: "", gender: "", degree: "") //will be overidden by the actual data

    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("birthday screen ", registerInfoStruct)
    }
    
    
}
