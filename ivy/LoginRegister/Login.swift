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

class Login: UIViewController, UITextFieldDelegate {
    
    // MARK: Variables and Constants
    
    private let authInstance = Auth.auth()
    private var thisUni = ""
    var dontAutoLog = false
    
    
    
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
    
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        navigationController?.setNavigationBarHidden(true, animated: animated)
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        navigationController?.setNavigationBarHidden(false, animated: animated)
//    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: Override and Base Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkAutoLogin()
        setUp()
        
        
//        let alert = UIAlertController(title: "Did you bring your towel?", message: "It's recommended you bring your towel before continuing.", preferredStyle: .alert)
//
//        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
//        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
//            print("Yay! You brought your towel!")
//        }))
//
//        self.present(alert, animated: true)
    }
    
    func setUp(){
        self.hideKeyboardOnTapOutside()
        emailField.delegate = self //set a delegate to the text fields (which is this view controller)
        passwordField.delegate = self
        emailField.tag = 0 //and give the text fields an order via tags
        passwordField.tag = 1
        let tap = UITapGestureRecognizer(target: self, action: #selector(Login.startRegistration)) //make a tap event handler that starts registration and attach it to the sign up label
        signupLabel.isUserInteractionEnabled = true
        signupLabel.addGestureRecognizer(tap)
        self.navigationController?.setNavigationBarHidden(true, animated: false) //hide navigation bar for this view controller
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool { //a function that handles return key press on user's keyboard
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField { //move to the next text field in order
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder() //remove keyboard if no other fields to go to
        }
        return false
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? MainTabController{
            vc.thisUniDomain = thisUni
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: UI Related Functions
    
    func fieldsOk() -> Bool{ //input checking for both text fields, if something's wrong with the input set an appropriate text to the error label
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
    
    func hideElems(){ //in a case of auto login hide everything except the top container (which contains the ivy logo so that we can still display the loading animation)
        middleContainer.isHidden = true
        bottomContainer.isHidden = true
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: Authentication Functions
    
    func attemptLogin(){
        errorLabel.text = ""
        if(fieldsOk()){
            barInteraction()
            let email = emailField.text!
            let password = passwordField.text!
            authInstance.signIn(withEmail: email, password: password) { (result, error) in //try to authenticate user in Firebase Auth with their email and password
                if(error == nil){
                    if(self.authInstance.currentUser!.isEmailVerified){
                        if let range = email.range(of: "@") { //extract the domain the user's entered
                            self.thisUni = String(email[range.upperBound...])
                            self.thisUni = self.thisUni.trimmingCharacters(in: .whitespacesAndNewlines) //trim whitespace and new line incase accidentley add space
                        }
                        self.saveLocalData() //save the uni domain locally (we'll need it for a future auto login)
                        self.performSegue(withIdentifier: "loginToMain" , sender: self)
                    }else{
                        self.errorLabel.text = "You need to verify your email address before you can log in. Didn't recieve an email? Click here to resend it."
                        let tap = UITapGestureRecognizer(target: self, action: #selector(Login.resendEmailValidation)) //make a tap event handler that starts registration and attach it to the sign up label
                        self.errorLabel.isUserInteractionEnabled = true
                        self.errorLabel.addGestureRecognizer(tap)
                        self.allowInteraction()
                    }
                    
                }else{
                    self.errorLabel.text = "Login failed, invalid email or password." //if the authentication fails let the user know through the error label
                    self.allowInteraction()
                }
            }
        }
    }
    
    //actually send the verification email
    @objc func resendEmailValidation() {
        Auth.auth().currentUser?.sendEmailVerification(completion: { (e) in
            if e != nil{
                print("error sending reg email: ",e)
                PublicStaticMethodsAndData.createInfoDialog(titleText: "Error", infoText: "There was an error sending the registration email. Please contact theivysocialnetwork@gmail.com.", context: self)
            }else{
                //nothing
            }
        })
        PublicStaticMethodsAndData.createInfoDialog(titleText: "Email Sent", infoText: "We sent you a verification email. Please check your inbox.", context: self)
    }
    
    
    func checkAutoLogin(){ //check if we the necessary local data and if the user has logged in in the past to attempt an auto login
        if(getLocalData() && authInstance.currentUser != nil  /*&& authInstance.currentUser!.isEmailVerified*/ && !dontAutoLog){
            saveLocalData()
            barInteraction()
            hideElems()
            self.performSegue(withIdentifier: "loginToMain", sender: self)
        }else{
            //errorLabel.text = "Couldn't perform auto-login, please log in manually."
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: Other Functions
    
    private func createResendEmailErrorText() -> NSMutableAttributedString{
        let strNumber: NSString = "Your email is not verified. Need to resend the verification email? Click here" as NSString // you must set your
        let range = (strNumber).range(of: "Click here")
        let attribute = NSMutableAttributedString.init(string: strNumber as String)
        attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.ivyGreen , range: range)
        return attribute
    }
    
    @objc func startRegistration(sender: UITapGestureRecognizer){ //move to the first registration view controller
        self.performSegue(withIdentifier: "loginToReg1Segue" , sender: self)
    }
    
    func saveLocalData(){ //save this user's university domain locally
        let defaults = UserDefaults.standard
        defaults.set(thisUni, forKey: "thisUni")
    }
    
    func getLocalData() -> Bool{ //get locally saved data
        let defaults = UserDefaults.standard
        if let thisUn = defaults.string(forKey: "thisUni") as? String{
            self.thisUni = thisUn
            return true
        }else{
            return false
        }
    } 
}

