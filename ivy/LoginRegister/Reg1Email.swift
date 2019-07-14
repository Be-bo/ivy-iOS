//
//  Reg1Email.swift
//  ivy
//
//  Created by Paul Dan on 2019-06-05.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseCore
import FirebaseFirestore

class Reg1Email: UIViewController {
    

    //initializers
    var domain = ""
    var emailInput = ""
    var confirmEmailInput = ""
    var registerInfoStruct = UserProfile()
    private let baseDatabaseReference = Firestore.firestore()   //reference to the database
    

    //outlets for labels
    @IBOutlet weak var emailLabel: StandardTextField!
    @IBOutlet weak var confirmEmailLabel: StandardTextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.isHidden = true //error label should be hidden by defualt
    }
    
    //when user clicks button to continue and outlet for the button
    @IBAction func onClickContinue(_ sender: Any) {
        attemptToContinue() //check if emails match, domain, etc..
    }
    
    //called every single time a segway is called
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! Reg2Password
        vc.registerInfoStruct.email = self.registerInfoStruct.email ?? "no email"
    }
    
    
    
    //check if we can continue onto the next registration screen
    func attemptToContinue() {
        self.emailInput = emailLabel.text!  //grab emaail from email label
        self.confirmEmailInput = confirmEmailLabel.text!    //grab confirm email
        
        if(emailInput.count>5 && emailInput.contains("@")){
            if(emailInput.isEqual(confirmEmailInput)){  //if emails match check against database to ensure domains match
                //extract domain
                if let range = emailInput.range(of: "@") {
                    domain = String(emailInput[range.upperBound...])
                    domain = domain.trimmingCharacters(in: .whitespacesAndNewlines)

                }

                checkDomain(domain: domain, emailInput: emailInput)
            }else { //no match, show error, display label
                errorLabel.text = "The emails don't match."
                errorLabel.isHidden = false
                //allowInteraction();
            }
        }else{//domains dont match or is not long enough, show error, display label
            errorLabel.text = "The email must contain an \"@\" and be at least six characters long."
            errorLabel.isHidden = false
            //allowInteraction();
        }
    }
    
    
    //check the domain to make sure its a valid domain
    func checkDomain(domain:String, emailInput:String) {
        
        //if domain is empty dont even check
        if (domain != ""){
            baseDatabaseReference.collection("universities").document(domain).getDocument { (document, error) in
                if let document = document, document.exists {
                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                    print("Document data: \(dataDescription)")
                    self.registerInfoStruct.email = self.emailInput //set struct email info to be that input for the label
                    self.performSegue(withIdentifier: "reg1ToReg2Segue" , sender: self) //pass data over to passsword screen
                } else {    //prompt the user informing that they must use a valid university email domain
                    print("Document does not exist")
                    self.errorLabel.text = "Please use a valid university email address"
                    self.errorLabel.isHidden = false
                }
            }
        }else{
            print("Document does not exist")
            self.errorLabel.text = "Please use a valid university email address"
            self.errorLabel.isHidden = false
        }
    }
    
    
}

