//
//  Reg2Password.swift
//  ivy
//
//  Created by paul dan on 2019-06-30.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import Foundation
import UIKit

class Reg2Password: UIViewController {
    

    var secondStruct = UserProfile(email:"") //initializer which will be overidden by the email actually passed in

    override func viewDidLoad() {
        super.viewDidLoad()
        print("password screen", secondStruct.email)
        
    }
    
    
}
