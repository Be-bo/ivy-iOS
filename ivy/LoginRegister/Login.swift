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
    @IBOutlet weak var forgotPassLabel: MediumGreenLabel!
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
        self.hideKeyboardOnTapOutside()
        emailField.delegate = self //set a delegate to the text fields (which is this view controller)
        passwordField.delegate = self
        emailField.tag = 0 //and give the text fields an order via tags
        passwordField.tag = 1
        let tapSignUp = UITapGestureRecognizer(target: self, action: #selector(Login.startRegistration)) //make a tap event handler that starts registration and attach it to the sign up label
        signupLabel.isUserInteractionEnabled = true
        signupLabel.addGestureRecognizer(tapSignUp)
        
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
                forgotPassLabel.text = "Forgot password?"
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
        
//        self.showTextInputDialog(title: "Add number",
//                        subtitle: "Please enter the new number below.",
//                        actionTitle: "Send",
//                        cancelTitle: "Cancel",
//                        inputPlaceholder: "New number",
//            inputKeyboardType: .default)
//        { (input:String?) in
//            print("The new number is \(input ?? "")")
//        }
//
//        self.alertWithTextField(title: "bork", message: "borkborkbork", placeholder: "bork?") { result in
//            print(result)
//        }
        
        let alert = UIAlertController(title: "titleText", message: "infoText", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true)
        
    }
    
    @objc func alertWithTextField(title: String? = nil, message: String? = nil, placeholder: String? = nil, completion: @escaping ((String) -> Void) = { _ in }) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField() { newTextField in
            newTextField.placeholder = placeholder
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in completion("") })
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { action in
            if
                let textFields = alert.textFields,
                let tf = textFields.first,
                let result = tf.text
            { completion(result) }
            else
            { completion("") }
        })
        self.present(alert, animated: true)
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
        self.baseDatabaseReference.collection("other").document("version_document").getDocument { (docSnap, e) in
            if(e != nil){
                print("There was an error obtaining app's version: ",e)
                self.performSegue(withIdentifier: "loginToMain", sender: self)
            }else{
                self.allowInteraction()
                if let verDic = docSnap?.data() as? Dictionary<String, Any>, let latest = verDic["iOS"] as? String, let local = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String, latest != local { //check if the doc's ok and whether the version is up to date
                    let alert = UIAlertController(title: "There's a newer version of the app available.", message: .none, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alert:UIAlertAction) in
                        
                        var url  = NSURL(string: "itms-apps://itunes.apple.com/app/bars/id1479966843")
                        if UIApplication.shared.canOpenURL(url! as URL) {
                            UIApplication.shared.openURL(url! as URL)
                        }
//                        self.performSegue(withIdentifier: "loginToMain", sender: self)
                    }))
                    
                    alert.addAction(UIAlertAction(title: "Update Later", style: .cancel, handler: { (alert:UIAlertAction) in
                        self.performSegue(withIdentifier: "loginToMain", sender: self)
                    }))
                    
                    
                    self.present(alert, animated: true)
                }else{
                    self.performSegue(withIdentifier: "loginToMain", sender: self)
                }
            }
        }
    }
}


extension UIViewController {
    func showTextInputDialog(title:String? = nil,
                         subtitle:String? = nil,
                         actionTitle:String? = "Send",
                         cancelTitle:String? = "Cancel",
                         inputPlaceholder:String? = nil,
                         inputKeyboardType:UIKeyboardType = UIKeyboardType.default,
                         cancelHandler: ((UIAlertAction) -> Swift.Void)? = nil,
                         actionHandler: ((_ text: String?) -> Void)? = nil) {

        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        alert.addTextField { (textField:UITextField) in
            textField.placeholder = inputPlaceholder
            textField.keyboardType = inputKeyboardType
        }
        alert.addAction(UIAlertAction(title: cancelTitle, style: .destructive, handler: cancelHandler))

        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { (action:UIAlertAction) in
            guard let textField =  alert.textFields?.first else {
                actionHandler?(nil)
                return
            }
            actionHandler?(textField.text)
        }))

        self.present(alert, animated: true, completion: nil)

    }
}
