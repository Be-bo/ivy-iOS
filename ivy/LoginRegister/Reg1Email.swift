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

class Reg1Email: UIViewController, UITextFieldDelegate {
    

    // MARK: Varibles and Constants
    
    var uni_domain = ""
    var emailInput = ""
    var confirmEmailInput = ""
    var registerInfoStruct = UserProfile()
    private let baseDatabaseReference = Firestore.firestore()   //reference to the database
    
    

    // MARK: IBOutlets and IBActions
    
    @IBOutlet weak var ivyLogo: UIImageView!
    @IBOutlet weak var emailLabel: StandardTextField!
    @IBOutlet weak var confirmEmailLabel: StandardTextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBAction func onClickContinue(_ sender: Any) {
        attemptToContinue()
    }
    
    
    //to reappear the top bar 
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController!.navigationBar.isHidden = false

    }
    
    
    
    // MARK: Base and Override Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false) //show navigation bar
        self.hideKeyboardOnTapOutside()
        emailLabel.delegate = self //set this view controller to delegate the text fields
        confirmEmailLabel.delegate = self
        emailLabel.tag = 0 //give both texfields order in which they're supposed to be edited
        confirmEmailLabel.tag = 1
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //called every single time a segue is called
        let vc = segue.destination as! Reg2Password
        vc.registerInfoStruct.email = self.registerInfoStruct.email ?? "no email"
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool { //a function that handles return key press on user's keyboard
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField { //move to the next text field in order
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder() //remove keyboard if no other fields to go to
        }
        return false
    }
    
    
    
    
    
    
    
    // MARK: Database Functions
    
    func checkDomain(domain:String, emailInput:String) { //check the domain to make sure its a valid domain
        if (domain != ""){//if domain is empty dont even check
            baseDatabaseReference.collection("universities").document(domain).getDocument { (document, error) in
                if let document = document, document.exists {
                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                    print("Document data: \(dataDescription)")
                    self.registerInfoStruct.email = self.emailInput //set struct email info to be that input for the label
                    self.allowInteraction()
                    self.performSegue(withIdentifier: "reg1ToReg2Segue" , sender: self) //pass data over to passsword screen
                } else {    //prompt the user informing that they must use a valid university email domain
                    print("Document does not exist")
                    self.errorLabel.text = "Please use a valid university email address"
                    self.errorLabel.isHidden = false
                    self.allowInteraction();
                }
            }
        }else{
            print("Document does not exist")
            self.errorLabel.text = "Please use a valid university email address"
            self.errorLabel.isHidden = false
            self.allowInteraction();
        }
    }
    
    
    
    
    
    
    
    
    // MARK: UI Related Functions
    
    func attemptToContinue() { //check if we can continue onto the next registration screen
        barInteraction()
        self.emailInput = emailLabel.text!
        self.confirmEmailInput = confirmEmailLabel.text!
        if(emailInput.count>5 && emailInput.contains("@")){
            if(emailInput.isEqual(confirmEmailInput)){  //if emails match check against database to ensure domains match
                if let range = emailInput.range(of: "@") { //extract domain from user's input
                    uni_domain = String(emailInput[range.upperBound...])
                    uni_domain = uni_domain.trimmingCharacters(in: .whitespacesAndNewlines) //trime whitespace/newline to force them without space
                }
                checkDomain(domain: uni_domain, emailInput: emailInput)
            }else { //no match display error label with error
                errorLabel.text = "The emails don't match."
                errorLabel.isHidden = false
                allowInteraction();
            }
        }else{//domains dont match or is not long enough, show error, display label
            errorLabel.text = "The email must contain an \"@\" and be at least six characters long."
            errorLabel.isHidden = false
            allowInteraction();
        }
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

