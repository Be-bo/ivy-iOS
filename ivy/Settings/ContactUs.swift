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
                    //TODO: allowInteraction()
                    let alert = UIAlertController(title: "Submission failed, check your internet connection or try restarting the app.", message: .none , preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                }
                //else task is succesful
                let alert = UIAlertController(title: "Your feedback is in! Thanks for contacting us!", message: .none , preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self.present(alert, animated: true)
                //TODO: allowInteraction()
                //clear the message label
                self.messageInputBox.text = ""
                //actually dismiss the view so we can clickon stuff again
            })
        }
        
    }
    
    
    
}
