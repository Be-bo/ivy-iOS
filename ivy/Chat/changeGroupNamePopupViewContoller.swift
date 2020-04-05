//
//  changeGroupNamePopupViewContoller.swift
//  ivy
//
//  Created by paul dan on 2019-08-19.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

class changeGroupNamePopupViewController: UIViewController,UITextViewDelegate, UITextFieldDelegate {
    
    //initializers
    var thisUserProfile = Dictionary<String, Any>()     //holds the current user profile
    var thisConversation = Dictionary<String, Any>()    //this current conversationboject
    let baseDatabaseReference = Firestore.firestore()   //reference to the database
    let baseStorageReference = Storage.storage()    //reference to storage
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear.withAlphaComponent(0.5)
        groupNameTextField.text = self.thisConversation["name"] as! String
    }
    
    
    @IBOutlet weak var groupNameTextField: UITextField!
    
    //when user click "save" button, do the stuff required to save new group name, then leave this view
    @IBAction func onClickSave(_ sender: Any) {
        
        let oldGroupName = self.thisConversation["name"] as! String
        let newGroupName = groupNameTextField.text
        
        //5 char long & not = to old name
        if (((newGroupName?.trimmingCharacters(in: .whitespacesAndNewlines).count)!) >= 5 && newGroupName != oldGroupName){
            self.baseDatabaseReference.collection("conversations").document(self.thisConversation["id"] as! String).updateData(["name": newGroupName])
        }else{
            PublicStaticMethodsAndData.createInfoDialog(titleText: "Invalid Action", infoText: "Please ensure the length of the new name is at least 5.", context: self)
        }
        
        
        
        
        //removeview to go back to chat
        self.view.removeFromSuperview()
        dismiss(animated: true, completion: nil)    //actually dismiss the view so we can clickon stuff again
    }
    
    
}
