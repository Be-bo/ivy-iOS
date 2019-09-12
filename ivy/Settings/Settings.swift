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
    @IBOutlet weak var insideScrollView: UIView!
    
    //Account Info
    @IBOutlet weak var namePreference: StandardLabel!
    @IBOutlet weak var universityPreference: StandardLabel!
    @IBOutlet weak var regDatePreference: StandardLabel!
    
    
    
    
    
    @IBOutlet weak var aboutView: UIView!
    @IBOutlet weak var supportView: UIView!
    @IBOutlet weak var privacyView: UIView!
    @IBOutlet weak var accInfoView: UIView!
    
    @IBOutlet weak var otherView: UIView!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Actions", style: .plain, target: self, action: #selector(showActions))
        //make sure we actually have the user profile
        if(!self.thisUserProfile.isEmpty){
            setUpHandlers()
            setAccountInfo()
            accInfoView.addLine(position: .LINE_POSITION_BOTTOM, color: .darkGray, width: 0.5)
            privacyView.addLine(position: .LINE_POSITION_BOTTOM, color: .darkGray, width: 0.5)
            supportView.addLine(position: .LINE_POSITION_BOTTOM, color: .darkGray, width: 0.5)
//            aboutView.addLine(position: .LINE_POSITION_BOTTOM, color: .darkGray, width: 0.5)

        }
        
        
        
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
        if let millis = thisUserProfile["registration_millis"] as? Int64{
            let time = Date.init(milliseconds: millis)
            var calendarDate = Calendar.current.dateComponents([.day, .year, .month], from: time)
            var day = "Unknown Day"
            var year = "Unknown Year"
            var month = "Unknown Month"
            if let dayInt = calendarDate.day{
                day = String(dayInt)
            }
            if let yearInt = calendarDate.year{
                year = String(yearInt)
            }
            if let monthInt = calendarDate.month{
                month = String(monthInt)
            }
            let retVal = month+"/"+day+"/"+year
            regDatePreference.text = "Registration Date: " + retVal
        }else{
            regDatePreference.text = "Registration Date Unknown"
        }
    }
    
    
    @IBAction func onClickChangePass(_ sender: Any) {
        self.performSegue(withIdentifier: "settingsToChangePassword" , sender: self) //pass data over to
    }
    
    
    @IBAction func onClickBlockedAcc(_ sender: Any) {
        self.performSegue(withIdentifier: "settingsToBlockedAcc" , sender: self) //pass data over to
    }
    
    
    @IBAction func onClickHide(_ sender: Any) {
        
        var isHidden = self.thisUserProfile["profile_hidden"] as! Bool
        print("is hidden", isHidden)
        if(!isHidden){
            let alert = UIAlertController(title: "You'll only be visible to your friends (nobody will be able to look you up or see you in Suggested Friends). Proceed?", message: .none, preferredStyle: .alert)
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
    
    
    @IBAction func legalStuffClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "settingsToLegalStuff" , sender: self)
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

enum LINE_POSITION {
    case LINE_POSITION_TOP
    case LINE_POSITION_BOTTOM
}

extension UIView {
    func addLine(position : LINE_POSITION, color: UIColor, width: Double) {
        let lineView = UIView()
        lineView.backgroundColor = color
        lineView.translatesAutoresizingMaskIntoConstraints = false // This is important!
        self.addSubview(lineView)
        
        let metrics = ["width" : NSNumber(value: width)]
        let views = ["lineView" : lineView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[lineView]|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))
        
        switch position {
        case .LINE_POSITION_TOP:
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[lineView(width)]", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))
            break
        case .LINE_POSITION_BOTTOM:
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[lineView(width)]|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))
            break
        }
    }
}
