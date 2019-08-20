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


class Reg10Recap: UIViewController {
    
    //initializers
    var password = ""   //carried over
    var registerInfoStruct = UserProfile(age:"", banned: nil, bio: "", birth_time: nil, degree: "", email: "", first_name: "", gender: "") //will be overidden by the actual data
    private var showingBack = false
    let front = Bundle.main.loadNibNamed("CardFront", owner: nil, options: nil)?.first as! CardFront
    let back = Bundle.main.loadNibNamed("CardBack", owner: nil, options: nil)?.first as! CardBack
    private var domain = "" //ex:ucalgary.ca
    private let baseDatabaseReference = Firestore.firestore()   //reference to the database
    // Get a reference to the storage service using the default Firebase App
    let baseStorageReference = Storage.storage()
    var imageByteArray:NSData? =  nil

    
    //outlets
    @IBOutlet weak var cardContainer: UIView!



    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpContainer()
        let frontImage = UIImage(data: self.imageByteArray! as Data,scale: 1.0)
        front.frame = cardContainer.bounds
        back.frame = cardContainer.bounds
        front.img.image = frontImage
        cardContainer.addSubview(front)
        
        var firstAndLast = self.registerInfoStruct.first_name! + " " + self.registerInfoStruct.last_name!
        var age = "10"
        back.age.text = age
        back.name.text = firstAndLast
        back.degree.text = self.registerInfoStruct.degree!
        back.bio.text = self.registerInfoStruct.bio!
        
        //extract domain from user struct to specify the uni_domain field
        if let range = self.registerInfoStruct.email!.range(of: "@") {
            domain = String(self.registerInfoStruct.email![range.upperBound...])
            domain = domain.trimmingCharacters(in: .whitespacesAndNewlines)
            self.registerInfoStruct.uni_domain = domain //set the structures uni comain to be ex: ucalgary.ca
        }
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(flip))
        singleTap.numberOfTapsRequired = 1
        cardContainer.addGestureRecognizer(singleTap)
    }
    
    
    @IBAction func onClickRegister(_ sender: Any) {
        attemptToContinue()
    }
    
    func attemptToContinue() {
        createUser()
        //        baseDatabaseReference.collection("universities").document(self.domain).collection("userprofiles")
    }
    
    //crdating the user using firebase auth.
    func createUser() {
        Auth.auth().createUser(withEmail: self.registerInfoStruct.email!, password: self.password) { authResult, error in
            if ((error) != nil){
                print("There was an error creating the user in the database", error)
            }else {
                self.databaseRegister()  //register the Userprofile struct associated with this user
            }
        }
    }
    
    //function dealing with actually registering the user into the database
    func databaseRegister() {

        let user = Auth.auth().currentUser  //get the current user that was just created above
        if let user = user {
            let uid = user.uid  //user id unique to firebase project
            self.registerInfoStruct.id = uid
        }
        
        
        //firebase STORAGE path to save the user image byte array
        let uuid = NSUUID().uuidString
        let storagePath = "userimages/" + self.registerInfoStruct.id! + "/" + uuid + ".jpg"
        
        // Create a storage reference from our storage service
        let storageRef = baseStorageReference.reference()
        let storageImageRef = storageRef.child(storagePath)

        
        // Upload the file to the path storagePath
        let uploadTask = storageImageRef.putData(self.imageByteArray! as Data, metadata: nil) { (metadata, error) in
                //TODO uncomment when need file metadata/downloadURL, maybe keep for now until decide if needed or not
//            guard let metadata = metadata else {
//                // Uh-oh, an error occurred!
//                return
//            }
            // Metadata contains file metadata such as size, content-type.
//            let size = metadata.size
            // You can also access to download URL after upload.
//            storageImageRef.downloadURL { (url, error) in
//                guard let downloadURL = url else {
//                    // Uh-oh, an error occurred!
//                    return
//                }
//            }
        }
        
        // Upload completed successfully
        uploadTask.observe(.success) { snapshot in
            var picArray = [String]()   //pic array holding the uploaded images the user can have
            picArray.append(storagePath)    //append the storage reference path to that profile picture since thats an uploaded image
//            self.getPreviewBytes()
            let previewImage = UIImage(data: self.imageByteArray! as Data,scale: 0.25)  //compress the image with the scale
            let previewImageBytes = (previewImage!.jpegData(compressionQuality: 0.25)!) as NSData//convert the compressed image back to bytes
            self.registerInfoStruct.picture_references = picArray
            self.registerInfoStruct.profile_picture = storagePath    //storage path where users profile pic is stored
            self.registerInfoStruct.registration_millis = String(CACurrentMediaTime() * 1000)    //seconds * 1000 = milliseconds
            self.registerInfoStruct.last_post_id = "" ///initialize
            self.registerInfoStruct.banned = false  //not banned by default
            self.registerInfoStruct.profile_hidden = false //not hidden by default
            self.baseDatabaseReference.collection("universities").document(self.domain).collection("userprofiles").document(self.registerInfoStruct.id!).setData(self.registerInfoStruct.dictionary)
            storageRef.child("userimages").child(self.registerInfoStruct.id!).child("preview.jpg").putData(previewImageBytes as Data)
            self.leaveForLogin()
        }
        
        //upload task failed
        uploadTask.observe(.failure) { snapshot in
            if let error = snapshot.error as NSError? {
                switch (StorageErrorCode(rawValue: error.code)!) {
                case .objectNotFound:
                    print("File doesn't exist")
                    break
                case .unauthorized:
                    print("User doesn't have permission to access file")
                    break
                case .cancelled:
                    print("User canceled the upload")
                    break
                case .unknown:
                    print("unknown error")
                    break
                default:
                    print("retry the upload here if it fails")
                    break
                }
            }
        }
    }


    func leaveForLogin() {
        self.performSegue(withIdentifier: "reg10ToLogin" , sender: self) //pass data over to
    }
    
    @objc func flip() {
        let toView = showingBack ? front : back
        let fromView = showingBack ? back : front
        UIView.transition(from: fromView, to: toView, duration: 1, options: .transitionFlipFromRight, completion: nil)
        showingBack = !showingBack
        setUpContainer()
        
    }
    
    func setUpContainer(){
        cardContainer.layer.shadowPath = UIBezierPath(roundedRect: cardContainer.bounds, cornerRadius:cardContainer.layer.cornerRadius).cgPath
        cardContainer.layer.shadowColor = UIColor.black.cgColor
        cardContainer.layer.shadowOpacity = 0.25
        cardContainer.layer.shadowOffset = CGSize(width: 2, height: 2)
        cardContainer.layer.shadowRadius = 5
        cardContainer.layer.cornerRadius = 5
        cardContainer.layer.masksToBounds = false
    }
    

    
}

