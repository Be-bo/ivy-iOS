//
//  ContactUs.swift
//  ivy
//
//  Created by paul dan on 2019-09-03.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

class ContactUs: UIViewController{
    
    private let baseDatabaseReference = Firestore.firestore()                    //reference to the database
    private let baseStorageReference = Storage.storage().reference()                         //reference to storage
    
    //passed through settings segue
    public var thisUserProfile = Dictionary<String, Any>()
    
    @IBOutlet weak var messageLabel: MediumLabel!
    @IBOutlet weak var messageInputBox: UITextView!
    @IBOutlet weak var sendButton: StandardButton!
    
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    
    @IBAction func onClickSendMessage(_ sender: Any) {
        sendMessage()
    }
    
    
    func sendMessage() {
        //TODO: set error text visibility to none
        if(self.messageInputBox.text.count > 0){
            var feedbackPackage = Dictionary<String,Any>()
            feedbackPackage["user_id"] = self.thisUserProfile["id"] as! String
            feedbackPackage["message"] = self.messageInputBox.text
            feedbackPackage["read"] = false
            feedbackPackage["uni_domain"] = self.thisUserProfile["uni_domain"] as! String
            feedbackPackage["time"] = Date().timeIntervalSince1970
            self.baseDatabaseReference.collection("userfeedback").document(String(Date().timeIntervalSince1970)).setData(feedbackPackage, completion: { (error) in
                if error != nil {
                    //TODO: set the error text to be the print statement
                    //TODO: set visibility of error text to be shown
                    //TODO: allowInteraction()
                    print("Submission failed, check your internet connection or try restarting the app.")
                }
                //else task is succesful
                //TODO: prompt  the user with this print message
                print("Your feedback is in! Thanks for contacting us!")
                //TODO: allowInteraction()
                self.dismiss(animated: true, completion: nil)//TODO: amke sure we actually dismiss the view controller
            })
        }
        
    }
    
    
    
}
