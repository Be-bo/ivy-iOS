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
    
    // MARK: Variables and Constants
    
    private let authInstance = Auth.auth()
    private var thisUni = ""
    
    
    
    // MARK: IBOutlets and IBActions

    @IBOutlet weak var emailField: StandardTextField!
    @IBOutlet weak var passwordField: StandardTextField!
    @IBOutlet weak var signupLabel: UILabel!
    @IBOutlet weak var errorLabel: ErrorLabel!
    @IBOutlet weak var middleContainer: StandardButton!
    @IBOutlet weak var bottomContainer: UIView!
    @IBOutlet weak var ivyLogo: UIImageView!
    
    @IBAction func loginClicked(_ sender: Any) {
        attemptLogin()
    }
    

    
    
    
    
    // MARK: Override and Base Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkAutoLogin()
        setUp()
    }
    
    func setUp(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(Login.startRegistration))
        signupLabel.isUserInteractionEnabled = true
        signupLabel.addGestureRecognizer(tap)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    
    
    
    
    // MARK: Login Functions
    
    func attemptLogin(){
        errorLabel.text = ""
        if(fieldsOk()){
            barInteraction()
            let email = emailField.text!
            let password = passwordField.text!
            authInstance.signIn(withEmail: email, password: password) { (result, error) in
                if(error == nil){
                    if let range = email.range(of: "@") {
                        self.thisUni = String(email[range.upperBound...])
                        self.thisUni = self.thisUni.trimmingCharacters(in: .whitespacesAndNewlines)
                        print("logging in with domain: "+self.thisUni)
                    }
                    self.saveLocalData()
                    // TODO: segue w/ data
                }else{
                    self.errorLabel.text = "Login failed, invalid email or password."
                    self.allowInteraction()
                }
            }
        }
    }
    
    func checkAutoLogin(){
        if(getLocalData() && authInstance.currentUser != nil){
            barInteraction()
            hideElems()
            // TODO: segue w/ data
        }else{
            //errorLabel.text = "Couldn't perform auto-login, please log in manually."
        }
    }
    
    
    
    // MARK: Other Functions
    
    @objc func startRegistration(sender: UITapGestureRecognizer){
        self.performSegue(withIdentifier: "loginToReg1Segue" , sender: self)
    }
    
    func saveLocalData(){
        let defaults = UserDefaults.standard
        defaults.set(thisUni, forKey: "thisUni")
    }
    
    func getLocalData() -> Bool{
        let defaults = UserDefaults.standard
        if thisUni == defaults.string(forKey: "thisUni"){
            return true
        }else{
            return false
        }
    }
    
    
    
    // MARK: UI Related Functions
    
    func fieldsOk() -> Bool{
        let email = emailField.text
        let password = passwordField.text
        var retVal = true
        
        if(email != "" && password != ""){
            if(!(email?.contains("@"))! || !(email?.contains("."))! || email!.count < 5){
                errorLabel.text = "Your email is incorrect."
                retVal = false
            }
            else if(password!.count < 6) {
                errorLabel.text = "Your password is not long enough. Are you sure you entered it correctly?"
                retVal = false
            }
        }else{
            errorLabel.text = "Neither field can be empty."
            retVal = false
        }
        return retVal
    }
    
    func barInteraction(){
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
    
    func allowInteraction(){
        self.view.isUserInteractionEnabled = true
        ivyLogo.layer.removeAllAnimations()
    }
    
    func hideElems(){
        middleContainer.isHidden = true
        bottomContainer.isHidden = true
    }
}

