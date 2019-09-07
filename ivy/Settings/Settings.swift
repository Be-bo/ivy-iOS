//
//  Settings.swift
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

class Settings: UIViewController{

    private let baseDatabaseReference = Firestore.firestore()                    //reference to the database
    private let baseStorageReference = Storage.storage().reference()                         //reference to storage
    
    //passed through w.e segue leads to settings page
    public var thisUserProfile = Dictionary<String, Any>()

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var privacySecView: UIView!
    @IBOutlet weak var insideScrollView: UIView!
    
    //Account Info
    @IBOutlet weak var namePreference: StandardLabel!
    @IBOutlet weak var universityPreference: StandardLabel!
    @IBOutlet weak var regDatePreference: StandardLabel!
    

    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Actions", style: .plain, target: self, action: #selector(showActions))
        //make sure we actually have the user profile
        if(!self.thisUserProfile.isEmpty){
            
            setUpHandlers()
            setAccountInfo()
        }
        
        
        
    }
    
    
    
    //all the possible actions that a user can have on the conversation.
    @objc func showActions(){
        let actionSheet = UIAlertController(title: "Actions", message: .none, preferredStyle: .actionSheet)
        actionSheet.view.tintColor = UIColor.ivyGreen
        
        //if there friends add these options to option sheet
    
        actionSheet.addAction(UIAlertAction(title: "ChangePass ", style: .default, handler: self.onClickChangePass(_:)))
        actionSheet.addAction(UIAlertAction(title: "ContactUs", style: .default, handler: self.onClickContact(_:)))
        actionSheet.addAction(UIAlertAction(title: "BlockedAcc ", style: .default, handler: self.onClickBlockedAcc(_:)))
        
        actionSheet.addAction(UIAlertAction(title: "SignOut ", style: .default, handler: self.onClickSignOut(_:)))
        actionSheet.addAction(UIAlertAction(title: "Hide ", style: .default, handler: self.onClickHide(_:)))
        actionSheet.addAction(UIAlertAction(title: "delete ", style: .default, handler: self.onClickDeleteAcc(_:)))

            
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    
    
    //attach on click listeners to the different lables
    func setUpHandlers() {
        
        var singleTap = UITapGestureRecognizer(target: self, action: .none) //will be over ridden for the diff tap events
        
        
        //TODO: if profile hidden then move the toggle switch on.
        if (self.thisUserProfile["profile_hidden"] as! Bool){
            //setcheck to true
            print("profile is hidden")
        }else{
            //setcheck to  false
            print("profile is not hidden")
        }
        
        
        //blocked acc
//        singleTap = UITapGestureRecognizer(target: self, action: #selector(self.clickBlockedAccounts))
//        blockedAccPreference.isUserInteractionEnabled = true
//        blockedAccPreference.addGestureRecognizer(singleTap)
//
//        //Sign out
//        singleTap = UITapGestureRecognizer(target: self, action: #selector(self.clickSignOut))
//        signOutPreference.isUserInteractionEnabled = true
//        signOutPreference.addGestureRecognizer(singleTap)
//
//        //password
//        singleTap = UITapGestureRecognizer(target: self, action: #selector(self.clickPassword))
//        changePassPreference.isUserInteractionEnabled = true
//        changePassPreference.addGestureRecognizer(singleTap)
//
//        //Contact us
//        singleTap = UITapGestureRecognizer(target: self, action: #selector(self.clickContactUs))
//        contactUsPreference.isUserInteractionEnabled = true
//        contactUsPreference.addGestureRecognizer(singleTap)
//
//        //Hide
//        singleTap = UITapGestureRecognizer(target: self, action: #selector(self.clickHide))
//        hidePreference.isUserInteractionEnabled = true
//        hidePreference.addGestureRecognizer(singleTap)
//
//        //Delete
//        singleTap = UITapGestureRecognizer(target: self, action: #selector(self.clickDeleteAccount))
//        deleteAccPreference.isUserInteractionEnabled = true
//        deleteAccPreference.addGestureRecognizer(singleTap)
        
        
        
    }
    
    
    //populatethe labels with the right info
    func setAccountInfo() {
        
        //name
        var userFirst = self.thisUserProfile["first_name"] as! String
        var userLast = self.thisUserProfile["last_name"] as! String
        var userFirstAndLast = userFirst + " " + userLast
        namePreference.text = "Name: " + userFirstAndLast
        
        //uni
        if (self.thisUserProfile.contains(where: { $0.key == "university"}) ){
            let userUni = self.thisUserProfile["university"] as! String
            universityPreference.text = "University: " + userUni
        }else{
            let userDom = self.thisUserProfile["uni_domain"] as! String
            universityPreference.text = "University: " + userDom
        }
        
        //reg date
        var retVal = "registration date not set yet"
//        let regMilliTime = Date.init(milliseconds: Int64(self.thisUserProfile["registration_millis"] as! CLong)) //start time
//        var calendarDate = Calendar.current.dateComponents([.day, .year, .month], from: regMilliTime)
//        var month = regMilliTime.monthMedium //these work beautifully except that they're missing the day getter for some reason
//        var day = "Unknown Day"
//        var year = "Unknown Year"
//        if let dayInt = calendarDate.day{
//            day = String(dayInt)
//        }
//        if let yearInt = calendarDate.year{
//            year = String(yearInt)
//        }
//        retVal = month+"/"+day+"/"+year
        regDatePreference.text = retVal
        
        
        
        
    }
    
    
    @IBAction func onClickChangePass(_ sender: Any) {
        self.performSegue(withIdentifier: "settingsToChangePassword" , sender: self) //pass data over to
    }
    
    
    @IBAction func onClickBlockedAcc(_ sender: Any) {
        self.performSegue(withIdentifier: "settingsToBlockedAcc" , sender: self) //pass data over to
    }
    
    
    @IBAction func onClickHide(_ sender: Any) {
        
        var isHidden = self.thisUserProfile["profile_hidden"] as! Bool
        print("is hiddem", isHidden)
        if(!isHidden){
            let alert = UIAlertController(title: "You'll only be visible to your friends (nobody will be able to look you up or see you in the Quad). Proceed?", message: .none, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { action in
                self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userprofiles").document(self.thisUserProfile["id"] as! String).updateData(["profile_hidden": true],completion: { (error) in
                    if error != nil {
                        print("oops, an error")
                    } else {
                        //TODO: allowInteraction
                        //TODO: set the check toggle to  TRUE
                        self.thisUserProfile["profile_hidden"] = true
                    }
                })
            }))
            
            self.present(alert, animated: true)
        }else if(isHidden){
            let alert = UIAlertController(title: "Everybody will be able to look you up, see you in the Quad and send you friend requests. Proceed?", message: .none, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { action in
                self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userprofiles").document(self.thisUserProfile["id"] as! String).updateData(["profile_hidden": false],completion: { (error) in
                    if error != nil {
                        print("oops, an error")
                    } else {
                        //TODO: allowInteraction
                        //TODO: set the check toggle to  FALSE
                        self.thisUserProfile["profile_hidden"] = false
                    }
                })
            }))
            self.present(alert, animated: true)
            
        }
    }
    
    @IBAction func onClickContact(_ sender: Any) {
        self.performSegue(withIdentifier: "settingsToContact" , sender: self) //pass data over to

    }
    
    
    @IBAction func onClickLegal(_ sender: Any) {
    }
    
    @IBAction func onClickHelp(_ sender: Any) {
    }
    
    
    @IBAction func onClickAbout(_ sender: Any) {
    }
    
    
    @IBAction func onClickSignOut(_ sender: Any) {
        
        let user = Auth.auth().currentUser  //get the current user that was just created above
        if let user = user {
            try! Auth.auth().signOut()  //actually sign the user out
            self.performSegue(withIdentifier: "logoutSegue" , sender: self) //pass data over to
        }

    }
    
    @IBAction func onClickDeleteAcc(_ sender: Any) {
        //TODO: prompt the user with the delete account dialog box
        var deletionMerger = Dictionary<String,Any>()
        deletionMerger["being_deleted"] = true
        self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userprofiles").document(self.thisUserProfile["id"] as!  String).setData(deletionMerger, merge: true)
        
        var deletionObject = Dictionary<String,Any>()
        deletionObject["type"] = "user_deletion"
        deletionObject["target_id"] = self.thisUserProfile["id"] as! String
        deletionObject["uni_domain"] = self.thisUserProfile["uni_domain"] as! String
        self.baseDatabaseReference.collection("triggers").document().setData(deletionObject, completion: { (error) in
            if error != nil {
                //TODO: prompt the user with the print statement
                print("We couldn't get your data. Try restarting the app or contacting us.")
            } else {
                //TODO: prompt the user with the print statement
                print("request successful. Your account will be deleted within two weeks")
                //TODO: set timer, that quits the app after 3 seconds
            }
        })
    }
    
    
    
//    //OLD on clicks
//    //On clicks
//    func clickBlockedAccounts(alert: UIAlertAction!) {
//
//    }
//
//    func clickSignOut(alert: UIAlertAction!) {
//    }
//
//
//
//
//    func clickPassword(alert: UIAlertAction!) {
//    }
//
//    func clickContactUs(alert: UIAlertAction!) {
//
//    }
//
//    func clickHide(alert: UIAlertAction!) {
//
//
//    }
//
//    func clickDeleteAccount(alert: UIAlertAction!) {
//
//    }
//
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //called every single time a segue is called
        if segue.identifier == "settingsToChangePassword" {
            let vc = segue.destination as! ChangePassword
            vc.thisUserProfile = self.thisUserProfile
        }
        if segue.identifier == "settingsToContact" {
            let vc = segue.destination as! ContactUs
            vc.thisUserProfile = self.thisUserProfile
        }
        if segue.identifier == "settingsToBlockedAcc" {
            let vc = segue.destination as! BlockedAccounts
            vc.thisUserProfile = self.thisUserProfile
            vc.previousVC = self
        }

        

    }
    
    
    
}
