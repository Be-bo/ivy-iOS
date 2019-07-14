//
//  Reg2Password.swift
//  ivy
//
//  Reg2Password.swift
//  ivy
//
//  Created by paul dan on 2019-06-30.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseCore
import FirebaseFirestore

class Reg2Password: UIViewController {
    
    //initializers
    var password = ""
    var confirmPassword = ""
    var registerInfoStruct = UserProfile(email:"") //will be overidden by the actual data
    private let baseDatabaseReference = Firestore.firestore()   //reference to the database
    
    
    //outlets
    @IBOutlet weak var passwordLabel: StandardTextField!
    @IBOutlet weak var passwordConfirmLabel: StandardTextField!
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
        let vc = segue.destination as! Reg3FirstLastName
        vc.registerInfoStruct.email = self.registerInfoStruct.email ?? "no email"
        //wont be setting password here though since we don't wanna save that to our register info object
    }
    
    
    //check if we can continue onto the next registration screen
    func attemptToContinue() {
        self.password = passwordLabel.text!  //grab emaail from email label
        self.confirmPassword = passwordConfirmLabel.text!    //grab confirm email
        if(password.count > 5){
            if(password.isEqual(confirmPassword)){//passwords match so continue to next screen
                self.performSegue(withIdentifier: "passwordToPassSegue" , sender: self) //pass data over to
            }else{
                //allowInteraction();
                errorLabel.text = "The passwords don't match."
                errorLabel.isHidden = false
            }
        }else{
            //allowInteraction();
            errorLabel.text = "The password needs to be at least six characters long."
            errorLabel.isHidden = false
        }
    }
    
    
    
    

    
    
    
    
    
    
    
    
}
