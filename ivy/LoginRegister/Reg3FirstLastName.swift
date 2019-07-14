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

    //initializers
    var firstName = ""
    var lastName = ""
    var registerInfoStruct = UserProfile(email:"") //will be overidden by the actual data
    private let baseDatabaseReference = Firestore.firestore()   //reference to the database

    
    @IBOutlet weak var firstNameLabel: StandardTextField!
    @IBOutlet weak var lastNameLabel: StandardTextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.isHidden = true //error label should be hidden by defualt
    }
    
    //on click of continue button
    @IBAction func onClickContinue(_ sender: Any) {
        attemptToContinue()
    }
    
    //called every single time a segway is called
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! Reg4Gender
        vc.registerInfoStruct.email = self.registerInfoStruct.email ?? "no email"
        vc.registerInfoStruct.first = self.firstName
        vc.registerInfoStruct.last = self.lastName
    }
    
    
    //check if we can continue onto the next registration screen
    func attemptToContinue() {
        self.firstName = firstNameLabel.text!  //grab emaail from email label
        self.lastName = lastNameLabel.text!    //grab confirm email
        if(firstName.count > 1 && lastName.count > 1){
            self.performSegue(withIdentifier: "firstAndLastSegue", sender: self) //pass data over to
            //allowInteraction();
        }else{
            //allowInteraction();
            errorLabel.text = "Both names must contain at least two characters."
            errorLabel.isHidden = false
        }
    }
    
    
    
}
