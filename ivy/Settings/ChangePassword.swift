//
//  ChangePassword.swift
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


class ChangePassword: UIViewController{
    
    private let baseDatabaseReference = Firestore.firestore()                    //reference to the database
    private let baseStorageReference = Storage.storage().reference()                         //reference to storage

    private var thisUser = Auth.auth().currentUser
    
    //passed through segue from settings
    public var thisUserProfile = Dictionary<String, Any>()
    

    
    @IBOutlet weak var currentPassword: StandardTextField!
    @IBOutlet weak var newPassword: StandardTextField!
    @IBOutlet weak var confirmPassword: StandardTextField!
    @IBOutlet weak var changePasswordButton: StandardButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    
    @IBAction func onClickChangeButton(_ sender: Any) {
        attemptToChangePassword()
    }
    
    
    //actually change the users password
    func attemptToChangePassword() {
        //TODO: set error text visibility to none
        
        var currentOld:String = ""
        var currentNew:String = ""
        var currentConfirm:String = ""
        
        //extract what user typed into text fields
        currentOld = currentPassword.text ?? ""
        currentNew = newPassword.text ?? ""
        currentConfirm = confirmPassword.text ?? ""
        
        if(currentNew.count > 5 && currentConfirm.count > 5){
            if (currentConfirm == currentNew){
                let credential = EmailAuthProvider.credential(withEmail: self.thisUserProfile["email"] as! String, password: currentOld)
                self.thisUser!.reauthenticate(with: credential, completion: { (result, error) in
                    if let err = error {
                        let alert = UIAlertController(title: "We failed to re-authenticate you (your current password is probably incorrect).", message: .none , preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                        self.present(alert, animated: true)
                        //TODO: allowInteraction()
                    } else {
                        self.thisUser!.updatePassword(to: currentNew, completion: { (error) in
                            if let err = error {
                                let alert = UIAlertController(title: "There was an error updating your password, try restarting the app.", message: .none , preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                                self.present(alert, animated: true)
                            } else {
                                let alert = UIAlertController(title: "Password change succesfull! Logout to see changes! ", message: .none , preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                                self.present(alert, animated: true)
                                //clear all labels
                                self.currentPassword.text = ""
                                self.confirmPassword.text = ""
                                self.newPassword.text = ""
                            }
                            })
                    }
                    })

            }else{
                let alert = UIAlertController(title: "Passwords do not match.", message: .none , preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self.present(alert, animated: true)
                //TODO: allowInteraction()
            }
        }else{
            let alert = UIAlertController(title: "The new password needs to be at least 6 characters long.", message: .none , preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            //TODO: allowInteraction()
        }
        
        
        
    }
    
    

}
