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
    

    //initializers
    var emailInput = ""
    var confirmEmailInput = ""
    var registerInfoStruct = UserProfile()
    

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
        attemptToContinue()
//        self.emailInput = emailLabel.text! //grab email from email label
        //call attempt to continue
        self.registerInfoStruct.email = self.emailInput //set struct email info to be that input for the label
        performSegue(withIdentifier: "emailToPassSegue" , sender: self)
    }
    
    //called every single time a segway is called
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! Reg2Password
        vc.secondStruct.email = self.registerInfoStruct.email ?? "no email"
    }
    
    func attemptToContinue() {
        self.emailInput = emailLabel.text!  //grab emaail from email label
        self.confirmEmailInput = confirmEmailLabel.text!    //grab confirm email
      
        if(emailInput.count>5 && emailInput.contains("@")){
            if(emailInput.isEqual(confirmEmailInput)){  //if emails match check against database to ensure domains match
//                checkDomain(emailInput.substring(emailInput.index("@")+1), emailInput);
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
    
}

