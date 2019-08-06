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

class Reg2Password: UIViewController, UITextFieldDelegate {
    
    // MARK: Variables and Constants
    
    var password = ""
    var confirmPassword = ""
    var registerInfoStruct = UserProfile(email:"") //will be overidden by the actual data
    private let baseDatabaseReference = Firestore.firestore()   //reference to the database
    
    
    // MARK: IBOutlets and IBActions
    
    @IBOutlet weak var ivyLogo: UIImageView!
    @IBOutlet weak var passwordLabel: StandardTextField!
    @IBOutlet weak var passwordConfirmLabel: StandardTextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBAction func onClickContinue(_ sender: Any) {
        attemptToContinue()
    }
    
    
    
    
    
    // MARK: Base and Override Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardOnTapOutside()
        passwordLabel.delegate = self //set this view controller to delegate the text fields so that "textFieldsShouldReturn" can be called
        passwordConfirmLabel.delegate = self
        passwordLabel.tag = 0 //set the correct order to the text fields (when you're supposed to type into them) via tags
        passwordConfirmLabel.tag = 1
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //called every single time a segway is called
        let vc = segue.destination as! Reg3Name
        vc.registerInfoStruct.email = self.registerInfoStruct.email ?? "no email"
        vc.password = self.password //set the password
        //wont be setting password here though since we don't wanna save that to our register info object
    }
    
    func attemptToContinue() { //check if we can continue onto the next registration screen
        self.password = passwordLabel.text!  //grab emaail from email label
        self.confirmPassword = passwordConfirmLabel.text!    //grab confirm email
        if(password.count > 5){
            if(password.isEqual(confirmPassword)){//passwords match so continue to next screen
                self.performSegue(withIdentifier: "reg2ToReg3Segue" , sender: self) //pass data over to
            }else{
                allowInteraction();
                errorLabel.text = "The passwords don't match."
                errorLabel.isHidden = false
            }
        }else{
            allowInteraction();
            errorLabel.text = "The password needs to be at least six characters long."
            errorLabel.isHidden = false
        }
    }
    
    
    
    
    
    // MARK: UI Related Functions
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool { //a function that handles return key press on user's keyboard
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField { //move to the next text field in order
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder() //remove keyboard if no other fields to go to
        }
        return false
    }
    
    func barInteraction(){ //disable user interaction and start loading animation (rotating the ivy logo)
        self.view.isUserInteractionEnabled = false
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 1.3
        animationGroup.repeatCount = .infinity
        let easeOut = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = 0.0
        rotationAnimation.toValue = 2*Double.pi
        rotationAnimation.duration = 0.3
        rotationAnimation.timingFunction = easeOut
        animationGroup.animations = [rotationAnimation]
        
        ivyLogo.layer.add(animationGroup, forKey: "rotation")
    }
    
    func allowInteraction(){ //enable interaction again
        self.view.isUserInteractionEnabled = true
        ivyLogo.layer.removeAllAnimations()
    }
}
