//
//  Login.swift

//  ivy
//
//  Created by Robert on 2019-06-02.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class Login: UIViewController {
    
    // MARK: Variables and Constant

    @IBOutlet weak var emailField: StandardTextField!
    @IBOutlet weak var passwordField: StandardTextField!
    @IBOutlet weak var loginButton: StandardButton!
    @IBOutlet weak var signupLabel: UILabel!
    // TODO: Error Text
    
    private let authInstance = Auth.auth()
    private var thisUni = ""
    
    
    
    
    // MARK: Override Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkAutoLogin()
    }
    
    
    
    
    
    // MARK: Login Functions
    
    func attemptLogin(){
        if(fieldsOk()){
            
        }
    }
    
    func checkAutoLogin(){
        if(getLocalData()){
            
        }
    }
    
    
    
    // MARK: Other Functions
    
    func startRegistration(){
        
    }
    
    func saveLocalData(){
        let defaults = UserDefaults.standard
        defaults.set(thisUni, forKey: "thisUni")
    }
    
    func getLocalData() -> Bool{
        let defaults = UserDefaults.standard
        if thisUni == defaults.string(forKey: "thisUni") as! String{
            return true
        }else{
            return false
        }
    }
    
    
    
    // MARK: UI Related Functions
    // TODO: bool var to return (cuz the standard way doesn't work)
    func fieldsOk() -> Bool{
        let email = emailField.text
        let password = passwordField.text
        
        if(email != nil && password != nil){
            if(!(email?.contains("@"))! || !(email?.contains("."))! || email!.count < 5){
                // TODO: error text
                return false
            }
            if(password!.count < 6) {
                // TODO: error text
                return false
            }
        }else{
            // TODO: error text
            return false
        }
        return false
    }
    
    func barInteraction(){
        
    }
    
    func allowInteraction(){
        
    }
    
    func hideElems(){
        
    }


}

