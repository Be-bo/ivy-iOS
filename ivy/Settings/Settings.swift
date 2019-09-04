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
    @IBOutlet weak var namePreference: MediumLabel!
    @IBOutlet weak var universityPreference: MediumLabel!
    @IBOutlet weak var regDatePreference: MediumLabel!
    //Privacy&Security
    @IBOutlet weak var changePassPreference: MediumLabel!
    @IBOutlet weak var blockedAccPreference: MediumLabel!
    @IBOutlet weak var hidePreference: MediumLabel!
    //Support
    @IBOutlet weak var contactUsPreference: MediumLabel!
    //About
    @IBOutlet weak var legalStuffPreference: MediumLabel!
    @IBOutlet weak var helpPreference: MediumLabel!
    @IBOutlet weak var aboutIvyPreference: MediumLabel!
    //Other
    @IBOutlet weak var signOutPreference: MediumLabel!
    @IBOutlet weak var deleteAccPreference: MediumLabel!
    
    
    
    
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
    
        actionSheet.addAction(UIAlertAction(title: "ChangePass ", style: .default, handler: self.clickPassword))
        actionSheet.addAction(UIAlertAction(title: "ContactUs", style: .default, handler: self.clickContactUs))
        actionSheet.addAction(UIAlertAction(title: "BlockedAcc ", style: .default, handler: self.clickBlockedAccounts))
        
        actionSheet.addAction(UIAlertAction(title: "SignOut ", style: .default, handler: self.clickSignOut))
        actionSheet.addAction(UIAlertAction(title: "Hide ", style: .default, handler: self.clickHide))
        actionSheet.addAction(UIAlertAction(title: "delete ", style: .default, handler: self.clickDeleteAccount))

            
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
    
    
    
    
    
    //On clicks
    func clickBlockedAccounts(alert: UIAlertAction!) {
        self.performSegue(withIdentifier: "settingsToBlockedAcc" , sender: self) //pass data over to
    }
    
    func clickSignOut(alert: UIAlertAction!) {
        let user = Auth.auth().currentUser  //get the current user that was just created above
        if let user = user {
            //TODO: segue over to login activity
            try! Auth.auth().signOut()  //actually sign the user out
        }
    }
    


    
    func clickPassword(alert: UIAlertAction!) {
        self.performSegue(withIdentifier: "settingsToChangePassword" , sender: self) //pass data over to
    }
    
    func clickContactUs(alert: UIAlertAction!) {
        self.performSegue(withIdentifier: "settingsToContact" , sender: self) //pass data over to

    }
    
    func clickHide(alert: UIAlertAction!) {
        var isHidden = self.thisUserProfile["profile_hidden"] as! Bool
        //TODO: construct the dialog the prompts them with the options
        
        if(!isHidden){
            //TODO: set the text of the dialog box to be the print statement
            print("You'll only be visible to your friends (nobody will be able to look you up or see you in the Quad). Proceed?")
        }else{
            //TODO: set the text of the dialog box to be the print statement
            print("Everybody will be able to look you up, see you in the Quad and send you friend requests. Proceed?")
        }
        //TODO: set on click listener of the cancel button that when clicked just dismissed the dialog box
        
        
        //TODO: set on click listener for the confirm button, which when clicked will either hide or not hide the profile
        //TODO: move the below logic into the on click listener that will be set with the coenfirm button
        
        if (isHidden){
            self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userprofiles").document(self.thisUserProfile["id"] as! String).updateData(["profile_hidden": false],completion: { (error) in
                if error != nil {
                    print("oops, an error")
                } else {
                    //TODO: allowInteraction
                    //TODO: cancel the dialog box
                    //TODO: set the check toggle to  FALSE
                    self.thisUserProfile["profile_hidden"] = false
                }
            })
        }else{
            self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userprofiles").document(self.thisUserProfile["id"] as! String).updateData(["profile_hidden": true],completion: { (error) in
                if error != nil {
                    print("oops, an error")
                } else {
                    //TODO: allowInteraction
                    //TODO: cancel the dialog box
                    //TODO: set the check toggle to  TRUE
                    self.thisUserProfile["profile_hidden"] = true
                }
            })
        }
        
        
    }
    
    func clickDeleteAccount(alert: UIAlertAction!) {
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
        }

        

    }
    
    
    
}
