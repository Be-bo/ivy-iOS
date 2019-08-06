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

class Reg3Name: UIViewController, UITextFieldDelegate {

    // MARK: Variables and Constant
    
    var firstName = ""
    var lastName = ""
    var registerInfoStruct = UserProfile(email:"") //will be overidden by the actual data
    var password = ""   //carried over
    private let baseDatabaseReference = Firestore.firestore()   //reference to the database
    

    
    // MARK: IBOutlets and IBActions
    
    @IBOutlet weak var ivyLogo: UIImageView!
    @IBOutlet weak var firstNameLabel: StandardTextField!
    @IBOutlet weak var lastNameLabel: StandardTextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBAction func onClickContinue(_ sender: Any) {
        attemptToContinue()
    }
    
    
    
    
    
    
    
    // MARK: Base and Override Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardOnTapOutside()
        firstNameLabel.delegate = self //set this view controller to delegate the text fields
        lastNameLabel.delegate = self
        firstNameLabel.tag = 0 //set the correct order to the buttons via tags
        lastNameLabel.tag = 1
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //called every single time a segue is called
        let vc = segue.destination as! Reg4Gender
        vc.registerInfoStruct.email = self.registerInfoStruct.email ?? "no email"
        vc.registerInfoStruct.first_name = self.firstName
        vc.registerInfoStruct.last_name = self.lastName
        vc.password = self.password //set the password

    }
    
    func attemptToContinue() {//check if we can continue onto the next registration screen
        self.firstName = firstNameLabel.text!
        self.lastName = lastNameLabel.text!
        if(firstName.count > 1 && lastName.count > 1){
            self.performSegue(withIdentifier: "reg3ToReg4Segue", sender: self) //pass data over to the next screen
            allowInteraction()
        }else{
            errorLabel.text = "Both names must contain at least two characters."
            errorLabel.isHidden = false
            allowInteraction()
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
