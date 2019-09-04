//
//  ViewFullProfileActivity.swift
//  ivy
//
//  Created by Paulicius Daen on 2019-08-14.
//  Copyright © 2019 ivy social network. All rights reserved.
//

//this class is used when you actually click to view a users profile. So it should have the extra options appear where you can "report"/"block"/"message"

import Foundation
import UIKit
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import FirebaseFirestore

class ViewFullProfileActivity: UIViewController{

    // MARK: Variables and Constants
    
    var isFriend = Bool()
    var thisUserProfile = Dictionary<String,Any>()                              //current user that wants to view another profile
    var otherUserID:String? = nil                                               //other users ID that thisUserProfile was in conversation with
    //database references
    let baseDatabaseReference = Firestore.firestore()                           //reference to the database
    let baseStorageReference = Storage.storage().reference()                    //reference to storage
    
    var conversationID = ""                                                     //id of THIS current conversation
    var otherUserProfile = Dictionary<String, Any>()                            //guy your conversating with's profile
    private let cellId = "QuadCard"
    private var cardClicked:Card? = nil

    
    private var showingBack = false
    let front = Bundle.main.loadNibNamed("CardFront", owner: nil, options: nil)?.first as! CardFront
    let back = Bundle.main.loadNibNamed("CardBack", owner: nil, options: nil)?.first as! CardBack
    
    @IBOutlet weak var cardContainer: UIView!
    
    
    
    
    
    
    
    
    
    // MARK: Base Functions and Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Actions", style: .plain, target: self, action: #selector(showActions))
        getData()
        setUpContainer()
    }

    @objc func showActions(){ //all the possible actions that a user can have on the conversation
        let actionSheet = UIAlertController(title: "User Actions", message: .none, preferredStyle: .actionSheet)
        actionSheet.view.tintColor = UIColor.ivyGreen
        
        //if there friends add these options to option sheet
        if (isFriend){
            actionSheet.addAction(UIAlertAction(title: "Message ", style: .default, handler: self.messageUser))
            actionSheet.addAction(UIAlertAction(title: "Unfriend", style: .default, handler: self.unfriendUser))
            actionSheet.addAction(UIAlertAction(title: "Report ", style: .default, handler: self.reportUser))

        }else{  //not friends so these are only options
            actionSheet.addAction(UIAlertAction(title: "block ", style: .default, handler: self.blockUser))
            actionSheet.addAction(UIAlertAction(title: "Report ", style: .default, handler: self.reportUser))

        }
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    //called every single time a segway is called
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //handling different segue calls based on identitfier
        if segue.identifier == "conversationToMessages" {
            let vc = segue.destination as! ChatRoom
            vc.conversationID = self.conversationID   //pass the user profile object
            vc.thisUserProfile = self.thisUserProfile
        }
        
        if segue.identifier == "unfriendToMain" {
            let vc = segue.destination as! MainTabController
            vc.thisUniDomain = self.thisUserProfile["uni_domain"] as! String
        }
    }
    
    func leaveForMainActivity() {
        self.performSegue(withIdentifier: "unfriendToMain" , sender: self)
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
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: Individual Action Methods
    
    func blockUser(alert:UIAlertAction!){ //when the user clicks on block user send it here to actually block them
        
        let docData = [String: Any]()   //used to set the hashmap when there is no blocked_by list that exists for this user
        
        self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userprofiles").document(self.otherUserID!).collection("userlists").document("blocked_by").getDocument { (document, error) in
            if let document = document, document.exists {   //if who you are reporting has already been blocked by you, do nothing
            } else {//the user you are reporting has never been blocked by anyone so create that list
                print("Here")
                self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userprofiles").document(self.otherUserID!).collection("userlists").document("blocked_by").setData(docData)
            }
            //then append to that list to add that you YOURSELF blocked that user and what time you blocked them at
            self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userprofiles").document(self.otherUserID!).collection("userlists").document("blocked_by").updateData([self.thisUserProfile["id"] as! String: Date().millisecondsSince1970,
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Or here")
                    print("Document successfully updated")
                }
            }
        }
    }
    
    func reportUser(alert: UIAlertAction!){ //when they click on reporting the USER send them here
        var report = Dictionary<String, Any>()
        report["reportee"] = self.thisUserProfile["id"] as! String
        report["report_type"] = "user"
        report["target"] = self.otherUserID //this current conversation id
        report["time"] = Date().millisecondsSince1970
        let reportId = self.baseDatabaseReference.collection("reports").document().documentID   //create unique id for this document
        report["id"] = reportId
        self.baseDatabaseReference.collection("reports").whereField("reportee", isEqualTo: self.thisUserProfile["id"] as! String).whereField("target", isEqualTo: self.otherUserID).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                if(!querySnapshot!.isEmpty){
                    print("You have already reported this user.")
                    PublicStaticMethodsAndData.createInfoDialog(titleText: "Invalid Action", infoText: "You have already reported this user.", context: self)
                }else{
                    self.baseDatabaseReference.collection("reports").document(reportId).setData(report)
                    print("This user has been reported.")
                    PublicStaticMethodsAndData.createInfoDialog(titleText: "Success", infoText: "The user has been reported.", context: self)
                }
            }
        }
    }
    
    func unfriendUser(alert: UIAlertAction!){ //when you want to unfriend a user execute this
        self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userprofiles").document(self.thisUserProfile["id"] as! String).collection("userlists").document("friends").getDocument { (document, error) in
            if let document = document, document.exists {
                let friendsList = document.data()!  //extract the friends list from the query
                if (!friendsList.isEmpty){
                    var conversationID = friendsList[self.otherUserID as! String]
                    
                    //remvove the field value  of the user from the friends field of this user
                    self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userprofiles").document(self.thisUserProfile["id"] as! String).collection("userlists").document("friends").updateData([self.otherUserID: FieldValue.delete(),
                    ]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully updated")
                        }
                    }
                    
                    //get rid of this users profile id from that other users friend list too so now we both aren't friends anymore :(
                    self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userprofiles").document(self.otherUserID!).collection("userlists").document("friends").updateData([self.thisUserProfile["id"] as! String: FieldValue.delete(),
                    ]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully updated")
                        }
                    }
                    
                    //delete the conversation these guys had going since they are no longer friends and you need to be friends to chat
                    self.baseDatabaseReference.collection("conversations").document(self.conversationID).delete() { err in
                        if let err = err {
                            print("Error removing document: \(err)")
                        } else {
                            self.leaveForMainActivity()
                        }
                    }
                }
                
                
                
            } else {
                print("document doesnt exist in unfriendUser()")
            }
        }
    }
    
    func messageUser(alert: UIAlertAction!){ //when they click message user, move over to the messaging user screen where you are actually in the conversation with the user
        self.performSegue(withIdentifier: "conversationToMessages" , sender: self) //pass data over to
    }
    
    
    
    
    
    
    
    
    
    
    // MARK: Data Acquisition Functions
    
    func getData() { //extract the data corresponding to this current conversation and this current user and who he is conversating with
        if (self.otherUserID != nil && !self.thisUserProfile.isEmpty){  //make sure there is a profile and there is another person in convo
            self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userprofiles").document(self.thisUserProfile["id"] as! String).collection("userlists").document("friends").getDocument { (document, error) in
                if let document = document, document.exists {
                    var friendsConversations = document.data()

                    //within the friends conversations make sure this guy's id is present
                    if friendsConversations![self.otherUserID as! String] != nil {
                        self.isFriend = true
                        self.conversationID = friendsConversations![self.otherUserID as! String] as! String
                    }else{
                        self.isFriend = false
                    }
                } else {    //document doesn't exist so they're not friends
                    self.isFriend = false
                }
                //extracting the other users profile object
                self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userprofiles").document(self.otherUserID!).getDocument { (document, error) in
                    if let document = document, document.exists {
                        self.otherUserProfile = document.data()!
                        if (!self.otherUserProfile.isEmpty){
                            self.bindData()
                        }

                    } else {
                        print("document doesnt exist in getData()")
                    }
                }
            }
        }
    }

    func bindData(){ //this method attaches the data obtained for the given user profile to the UI
        if let ref = otherUserProfile["profile_picture"] as? String{ //profile picture
            baseStorageReference.child(ref).getData(maxSize: 2 * 1024 * 1024) { (data, e) in
                if let e = e {
                    print("Error obtaining image: ", e)
                }else{
                    self.front.img.image = UIImage(data: data!)
                }
            }
        }
        
        if var degree = otherUserProfile["degree"] as? String { //degree icon
            degree = degree.replacingOccurrences(of: " ", with: "")
            degree = degree.lowercased()
            front.degreeIcon.image = UIImage(named: degree)
        }
        
        front.name.text = otherUserProfile["first_name"] as? String //text data
        back.name.text = String(otherUserProfile["first_name"] as? String ?? "Name") + " " + String(otherUserProfile["last_name"] as? String ?? "Name")
        back.degree.text = otherUserProfile["degree"] as? String
        back.age.text = otherUserProfile["age"] as? String
        back.bio.text = otherUserProfile["bio"] as? String
        back.setUpInterests(interests: otherUserProfile["interests"] as? [String] ?? [String]())
        
        front.frame = cardContainer.bounds
        back.frame = cardContainer.bounds
        cardContainer.addSubview(front)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(flip))
        singleTap.numberOfTapsRequired = 1
        cardContainer.addGestureRecognizer(singleTap)
    }
}

