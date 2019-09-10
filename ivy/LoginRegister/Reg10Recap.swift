//
//  Reg10Recap.swift
//  ivy
//
//  Created by Robert on 2019-07-07.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import InstantSearchClient


class Reg10Recap: UIViewController {
    
    // MARK: Variables and Constants
    
    var password = ""   //carried over
    var registerInfoStruct = UserProfile(age: 0, banned: nil, bio: "", birth_time: nil, degree: "", email: "", first_name: "", gender: "") //will be overidden by the actual data
    private var showingBack = false
    let front = Bundle.main.loadNibNamed("CardFront", owner: nil, options: nil)?.first as! CardFront
    let back = Bundle.main.loadNibNamed("CardBack", owner: nil, options: nil)?.first as! CardBack
    private var domain = "" //ex:ucalgary.ca
    private let baseDatabaseReference = Firestore.firestore()   //reference to the database
    private let baseStorageReference = Storage.storage()
    var imageByteArray:NSData? =  nil
    
    //outlets
    @IBOutlet weak var registerButton: StandardButton!
    @IBOutlet weak var progressWheel: UIActivityIndicatorView!
    
    @IBOutlet weak var shadowContainer: UIView!
    
    
    
    
    
    
    
    // MARK: Base Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let frontImage = UIImage(data: self.imageByteArray! as Data,scale: 1.0)
        back.frame = shadowContainer.bounds
        front.frame = shadowContainer.bounds
        front.img.image = frontImage
        front.name.text = self.registerInfoStruct.first_name!
        shadowContainer.addSubview(back)
        shadowContainer.addSubview(front)
        
        let firstAndLast = self.registerInfoStruct.first_name! + " " + self.registerInfoStruct.last_name!
        if let tiiime = registerInfoStruct.birth_time{
            let age = PublicStaticMethodsAndData.calculateAge(millis: tiiime)
            back.age.text = String(age)
        }
        back.name.text = firstAndLast
        front.name.text = firstAndLast
        back.degree.text = self.registerInfoStruct.degree!
        back.bio.text = self.registerInfoStruct.bio!
        back.setUpInterests(interests: self.registerInfoStruct.interests!)
        
        //hide the message field and the say hi button and the sync arrow since were flipping by clicking card
        back.flipButton.isHidden = true
        front.flipButton.isHidden = true
        back.sayHiMessageTextField.isHidden = true
        back.sayHiButton.isHidden = true
        
        //extract domain from user struct to specify the uni_domain field
        if let range = self.registerInfoStruct.email!.range(of: "@") {
            domain = String(self.registerInfoStruct.email![range.upperBound...])
            domain = domain.trimmingCharacters(in: .whitespacesAndNewlines)
            self.registerInfoStruct.uni_domain = domain //set the structures uni comain to be ex: ucalgary.ca
        }
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(flip))
        singleTap.numberOfTapsRequired = 1
        shadowContainer.addGestureRecognizer(singleTap)
    }
    
    @objc func flip() {
        let toView = showingBack ? front : back
        let fromView = showingBack ? back : front
        UIView.transition(from: fromView, to: toView, duration: 1, options: .transitionFlipFromRight) { (done) in
            self.shadowContainer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.shadowContainer.translatesAutoresizingMaskIntoConstraints = true
        }
        showingBack = !showingBack
    }
    
    @IBAction func onClickRegister(_ sender: Any) {
        let alert = UIAlertController(title: "Terms of Use", message: "To continue you have to agree to our Terms of Use.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Agree", style: .default, handler: { (action) in
            self.barInteraction()
            self.attemptToContinue()
        }))
        alert.addAction(UIAlertAction(title: "See Terms", style: .default, handler: { (action) in
            self.seeTerms()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func attemptToContinue() {
        createUser()
    }
    
    func seeTerms(){
        self.performSegue(withIdentifier: "reg10ToLegal" , sender: self)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: Database Methods
    
    func createUser() { //creating the user using firebase auth.
        Auth.auth().createUser(withEmail: self.registerInfoStruct.email!, password: self.password) { authResult, error in
            if ((error) != nil){
                print("There was an error creating the user in the database", error)
                PublicStaticMethodsAndData.createInfoDialog(titleText: "Error", infoText: "There was an error creating the user. Try restarting the app and check your internet connection", context: self)
            }else {
                if(Auth.auth().currentUser != nil){
                    Auth.auth().currentUser?.sendEmailVerification(completion: { (e) in
                        let alert = UIAlertController(title: "Registration Successful", message: "We sent you a verification email. Check your inbox.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                            //nothing
                        }))
                        self.present(alert, animated: true)
                    })
                }else{
                    PublicStaticMethodsAndData.createInfoDialog(titleText: "Error", infoText: "We couldn't authenticate your profile. Try restarting the app.", context: self)
                }
                self.databaseRegister()  //register the Userprofile struct associated with this user
            }
        }
    }
    
    func databaseRegister() { //function dealing with actually registering the user into the database
        let user = Auth.auth().currentUser  //get the current user that was just created above
        if let user = user {
            let uid = user.uid  //user id unique to firebase project
            self.registerInfoStruct.id = uid
        }
        
        let uuid = NSUUID().uuidString //firebase STORAGE path to save the user image byte array
        let storagePath = "userimages/" + self.registerInfoStruct.id! + "/" + uuid + ".jpg"
        
        let storageRef = baseStorageReference.reference() // Create a storage reference from our storage service
        let storageImageRef = storageRef.child(storagePath)

        
        // Upload the file to the path storagePath
        let uploadTask = storageImageRef.putData(self.imageByteArray! as Data, metadata: nil) { (metadata, error) in
        }
        
        // Upload completed successfully
        uploadTask.observe(.success) { snapshot in
            var picArray = [String]()   //pic array holding the uploaded images the user can have
            picArray.append(storagePath)    //append the storage reference path to that profile picture since thats an uploaded image
//            self.getPreviewBytes()
            let fullImage = UIImage(data: self.imageByteArray! as Data,scale: 1.0)  //compress the image with the scale
            let previewImage = PublicStaticMethodsAndData.compressPreviewImage(inputImage: fullImage!)
            let previewImageBytes = (previewImage.jpegData(compressionQuality: 0.8)!) as NSData//convert the compressed image back to bytes
            self.registerInfoStruct.picture_references = picArray
            self.registerInfoStruct.profile_picture = storagePath    //storage path where users profile pic is stored
            self.registerInfoStruct.registration_millis = Int64(CACurrentMediaTime() * 1000)    //seconds * 1000 = milliseconds
            self.registerInfoStruct.last_post_id = "" ///initialize
            self.registerInfoStruct.banned = false  //not banned by default
            self.registerInfoStruct.profile_hidden = false //not hidden by default
            storageRef.child("userimages").child(self.registerInfoStruct.id!).child("preview.jpg").putData(previewImageBytes as Data)
            self.baseDatabaseReference.collection("universities").document(self.domain).collection("userprofiles").document(self.registerInfoStruct.id!).setData(self.registerInfoStruct.dictionary, completion: { (e) in
                if(e != nil){
                    print("Error adding user's profile data to Firestore: ",e)
                }else{
                    self.initFCM() //init Firebase Cloud Messaging for this user (not utilized now, will come in handy later)
                    self.addUserToAlgolia() //add this user's search profile to Algolia for the Search feature
                }
            })
        }
        
        //upload task failed
        uploadTask.observe(.failure) { snapshot in
            if let error = snapshot.error as NSError? {
                switch (StorageErrorCode(rawValue: error.code)!) {
                case .objectNotFound:
                    print("File doesn't exist")
                    PublicStaticMethodsAndData.createInfoDialog(titleText: "Error", infoText: "The image you chose no longer exists.", context: self)
                    break
                case .unauthorized:
                    print("User doesn't have permission to access file")
                    PublicStaticMethodsAndData.createInfoDialog(titleText: "Error", infoText: "You don't have permission to access the profile image.", context: self)
                    break
                case .cancelled:
                    print("User canceled the upload")
                    PublicStaticMethodsAndData.createInfoDialog(titleText: "Error", infoText: "Upload cancelled.", context: self)
                    break
                case .unknown:
                    print("unknown error")
                    PublicStaticMethodsAndData.createInfoDialog(titleText: "Error", infoText: "An unknow error occurred, try restarting the app.", context: self)
                    break
                default:
                    print("retry the upload here if it fails")
                    break
                }
            }
        }
    }

    func addUserToAlgolia(){
        print("adding user to algolia")
        baseDatabaseReference.collection("other").document("algolia_update").getDocument { (docSnap, err) in //obtain app id and api key of our Algolia instance
            if err != nil{
                print("Failed to get Algolia info from Firestore: ", err!)
            }else{
                if docSnap?.exists ?? false, let algolUpdatDat = docSnap?.data(){
                    if let appId = algolUpdatDat["app_id"] as? String, let apiKey = algolUpdatDat["api_key"] as? String, let id = self.registerInfoStruct.id, let fName = self.registerInfoStruct.first_name, let lName = self.registerInfoStruct.last_name, let deg = self.registerInfoStruct.degree, let bio = self.registerInfoStruct.bio, let ints = self.registerInfoStruct.interests, let dom = self.registerInfoStruct.uni_domain{
                        let client = Client(appID: appId, apiKey: apiKey) //get Algolia's client
                        let index = client.index(withName: "search_USERS") //refer to the user search index
                        var jsonObject = [String: Any]() //and add the newly registered user
                        jsonObject["id"] = id
                        jsonObject["first_name"] = fName
                        jsonObject["last_name"] = lName
                        jsonObject["degree"] = deg
                        jsonObject["bio"] = bio
                        jsonObject["interests"] = ints
                        jsonObject["uni_domain"] = dom
                        index.z_objc_addObject(jsonObject, completionHandler: { (insertedObject, err) in
                            if err != nil, let obj = insertedObject{
                                print("Failed to put: ", obj, " into Algolia with error: ", err!)
                            }else{ //on success leave for login
                                self.leaveForLogin()
                            }
                        })
                    }
                }
            }
        }
    }
    
    func initFCM(){ //get instance id of this app and extract this device's FCM token from it
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                self.sendFCMRegistrationToServer(token: result.token)
            }
        }
    }
    
    func sendFCMRegistrationToServer(token: String){ //save the token inside of this user's profile
        var mergerDictionary = Dictionary<String, Any>()
        mergerDictionary["messaging_token"] = token
        if let uniDomain = registerInfoStruct.uni_domain, let thisId = registerInfoStruct.id{
            baseDatabaseReference.collection("universities").document(uniDomain).collection("userprofiles").document(thisId).setData(mergerDictionary, merge: true)
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: UI Functions

    func leaveForLogin() {
        self.performSegue(withIdentifier: "reg10ToLogin" , sender: self) //pass data over to
    }
    
    func barInteraction(){ //disable user interaction and start loading animation (rotating the ivy logo)
        self.view.isUserInteractionEnabled = false
        registerButton.isHidden = true
        progressWheel.startAnimating()
    }
    
    func allowInteraction(){ //enable interaction again
        self.view.isUserInteractionEnabled = true
        self.registerButton.isHidden = false
        progressWheel.stopAnimating()
    }

    
}

