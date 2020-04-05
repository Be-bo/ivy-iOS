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
    let baseDatabaseReference = Firestore.firestore()
    
    
    
    // MARK: IBOutlets and IBActions
    
    @IBOutlet weak var emailField: StandardTextField!
    @IBOutlet weak var passwordField: StandardTextField!
    @IBOutlet weak var signupLabel: UILabel!
    @IBOutlet weak var errorLabel: ErrorLabel!
    //    @IBOutlet weak var forgotPassLabel: MediumGreenLabel!
    @IBOutlet weak var middleContainer: StandardButton!
    @IBOutlet weak var bottomContainer: UIView!
    @IBOutlet weak var ivyLogo: UIImageView!
    @IBOutlet weak var forgotPassLabel: StandardGreenLabel!
    
    
    @IBAction func loginClicked(_ sender: Any) {
        attemptLogin()
    }
    
    
    //fix the error of when going to sign up and coming back the top bar held over
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController!.navigationBar.isHidden = true
        
    }
    
    // MARK: Override and Base Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkAutoLogin()
        setUp()
    }
    
    func setUp(){
        self.hideKeyboardOnTapOutside()
        emailField.delegate = self //set a delegate to the text fields (which is this view controller)
        passwordField.delegate = self
        emailField.tag = 0 //and give the text fields an order via tags
        passwordField.tag = 1
        let tapSignUp = UITapGestureRecognizer(target: self, action: #selector(Login.startRegistration)) //make a tap event handler that starts registration and attach it to the sign up label
        signupLabel.isUserInteractionEnabled = true
        signupLabel.addGestureRecognizer(tapSignUp)
        
        //TODO: forgot password stuff
        let tapForgotPass = UITapGestureRecognizer(target: self, action: #selector(Login.promptRecoveryEmail))
        forgotPassLabel.isUserInteractionEnabled = true
        forgotPassLabel.addGestureRecognizer(tapForgotPass)
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
        emailField.isHidden = true
        passwordField.isHidden = true
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
//                    if(self.authInstance.currentUser!.isEmailVerified){
                        if let range = email.range(of: "@") { //extract the domain the user's entered
                            self.thisUni = String(email[range.upperBound...])
                            self.thisUni = self.thisUni.trimmingCharacters(in: .whitespacesAndNewlines) //trim whitespace and new line incase accidentley add space
                        }
                        self.saveLocalData() //save the uni domain locally (we'll need it for a future auto login)
                        self.checkForNewerVersion()
//                    }else{
//                        self.errorLabel.attributedText = self.createResendEmailErrorText()
//                        let tap = UITapGestureRecognizer(target: self, action: #selector(Login.resendEmailValidation))
//                        self.errorLabel.isUserInteractionEnabled = true
//                        self.errorLabel.addGestureRecognizer(tap)
//                        self.allowInteraction()
//                    }
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
                PublicStaticMethodsAndData.createInfoDialog(titleText: "Email Sent", infoText: "We sent you a verification email. Please check your inbox.", context: self)
            }
        })
        
    }
    
    
    func checkAutoLogin(){ //check if we the necessary local data and if the user has logged in in the past to attempt an auto login
        if(getLocalData() && authInstance.currentUser != nil  /*&& authInstance.currentUser!.isEmailVerified*/ && !dontAutoLog){
            saveLocalData()
            barInteraction()
            hideElems()
            self.checkForNewerVersion()


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
    
    @objc func promptRecoveryEmail(sender: UITapGestureRecognizer){
        let ac = UIAlertController(title: "Type your email:", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned ac] _ in
            let emailInput = ac.textFields![0]
            
            //try to send reset email and if it works then prompt
            if let emailInput = emailInput.text {
                if(emailInput.count>5 && emailInput.contains("@")){
                    //check if auth is successfull and complete else tell them it might not have sent
                    Auth.auth().sendPasswordReset(withEmail: emailInput, completion: { (error) in
                        //Make sure you execute the following code on the main queue
                        DispatchQueue.main.async {
                            //Use "if let" to access the error, if it is non-nil
                            if let error = error {
                                let resetFailedAlert = UIAlertController(title: "Reset Failed", message: "User might not exist", preferredStyle: .alert)
                                resetFailedAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                self.present(resetFailedAlert, animated: true, completion: nil)
                            } else {
                                let resetEmailSentAlert = UIAlertController(title: "Reset email sent successfully", message: "Check your email", preferredStyle: .alert)
                                resetEmailSentAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                self.present(resetEmailSentAlert, animated: true, completion: nil)
                            }
                        }
                    })
                }else{
                    //prompt them to enter a valid email
                    PublicStaticMethodsAndData.createInfoDialog(titleText: "Please enter a valid email domain", infoText: "", context: self)
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { [unowned ac] _ in
        }
        ac.addAction(cancelAction)
        ac.addAction(submitAction)
        self.present(ac, animated: true)
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
    
    private func checkForNewerVersion(){
        self.baseDatabaseReference.collection("universities").document(thisUni).collection("userprofiles").document(self.authInstance.currentUser!.uid).updateData(["last_login_millis" : Date().millisecondsSince1970])

        self.baseDatabaseReference.collection("other").document("version_document").getDocument { (docSnap, e) in
            if(e != nil){
                print("There was an error obtaining app's version: ",e)
                self.updateMessagingToken()
                self.performSegue(withIdentifier: "loginToMain", sender: self)
            }else{
                self.allowInteraction()
                if let verDic = docSnap?.data() as? Dictionary<String, Any>, let latest = verDic["iOS"] as? String, let local = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String, latest != local { //check if the doc's ok and whether the version is up to date
                    let alert = UIAlertController(title: "There's a newer version of the app available.", message: .none, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alert:UIAlertAction) in
                        
                        let url  = NSURL(string: "itms-apps://itunes.apple.com/app/bars/id1479966843")
                        if UIApplication.shared.canOpenURL(url! as URL) {
                            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
                        }
                        //                        self.performSegue(withIdentifier: "loginToMain", sender: self)
                    }))
                    
                    alert.addAction(UIAlertAction(title: "Update Later", style: .cancel, handler: { (alert:UIAlertAction) in
                        self.updateMessagingToken()
                        self.performSegue(withIdentifier: "loginToMain", sender: self)
                    }))
                    
                    
                    self.present(alert, animated: true)
                }else{
                    self.updateMessagingToken()
                    self.performSegue(withIdentifier: "loginToMain", sender: self)
                }
            }
        }
    }
    
    func updateMessagingToken(){
        //Request for new token
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                if let id = Auth.auth().currentUser?.uid as? String{
                    var tokenMerger = Dictionary<String,Any>()
                    tokenMerger["messaging_token"] = result.token
                    self.baseDatabaseReference.collection("universities").document("ucalgary.ca").collection("userprofiles").document(id).setData(tokenMerger, merge: true)
                    
                }
                print("Remote instance ID token: \(result.token)")
            }
        }
        Messaging.messaging().shouldEstablishDirectChannel = true
    }
    
    
}


