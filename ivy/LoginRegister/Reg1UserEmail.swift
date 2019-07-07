//
//  Reg1UserEmail.swift
//  ivy
//
//  Created by Paul Dan on 2019-06-05.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import Foundation
import UIKit

class Reg1UserEmail: UIViewController {
    
    var emailText = ""
    
    struct RegisterInfoStruct {
        var email: String
    }


    @IBOutlet weak var emailLabel: StandardTextField!
    var registerInfoStruct: RegisterInfoStruct?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func onClickContinue(_ sender: Any) {
        emailText = emailLabel.text!
        performSegue(withIdentifier: "emailToPassSegue" , sender: self)
    }
    
    //called every single time a segway is called
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var vc = segue.destination as! Reg2Password
        vc.registerInfoStruct?.email = self.emailText
    }
    
}
