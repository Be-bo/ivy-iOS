//
//  ViewFullProfileActivity.swift
//  ivy
//
//  Created by paul dan on 2019-08-14.
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

class ViewFullProfileActivity: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    
    
    //INITITALIZERS
    //passed in from chatroom.swift segue
    var isFriend = Bool()
    var thisUserProfile = Dictionary<String,Any>()                              //current user that wants to view another profile
    var otherUserID:String? = nil                                               //other users ID that thisUserProfile was in conversation with
    //database references
    let baseDatabaseReference = Firestore.firestore()                           //reference to the database
    let baseStorageReference = Storage.storage()                                //reference to storage
    
    var conversationID = ""                                                     //id of THIS current conversation
    var otherUserProfile = Dictionary<String, Any>()                            //guy your conversating with's profile
    private let cellId = "QuadCard" 
    
    
    private var cardClicked:Card? = nil

    
    
    // MARK: IBOutlets and IBActions
    @IBOutlet weak var viewProfileCollectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Actions", style: .plain, target: self, action: #selector(showActions))
        getData()
        setUpCardCollectionView()
        // swift
        
        //TODO: get rid of collection view holder for cards. This is a temporary fix that doesn't allows scrolling of the collection view
        self.viewProfileCollectionView?.alwaysBounceVertical = false
        self.viewProfileCollectionView?.alwaysBounceHorizontal = false
        self.viewProfileCollectionView?.bounces = false
        self.viewProfileCollectionView?.isScrollEnabled = false
        
    }
    
    
    //all the possible actions that a user can have on the conversation.
    @objc func showActions(){
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
    
    //when the user clicks on block user send it here to actually block them
    func blockUser(alert:UIAlertAction!){
        
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
    
    
    //when they click on reporting the USER send them here
    func reportUser(alert: UIAlertAction!){
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
                }else{
                    self.baseDatabaseReference.collection("reports").document(reportId).setData(report)
                    print("This user has been reported.")
                }
            }
        }
    }
    
    
    //when you want to unfriend a user execute this
    func unfriendUser(alert: UIAlertAction!){
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
    
    //when they click message user, move over to the messaging user screen where you are actually in the conversation with the user
    func messageUser(alert: UIAlertAction!){
        self.performSegue(withIdentifier: "conversationToMessages" , sender: self) //pass data over to
    }
    
    
    
    
    
    //extract the data corresponding to this current conversation and this current user and who he is conversating with
    func getData() {
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
                            self.viewProfileCollectionView.reloadData() //load other users profile into card cell
                            //TODO: look into bind data
                            //TODO: look into what animprep is
                        }

                    } else {
                        print("document doesnt exist in getData()")
                    }
                }
            }
        }
    }
    
    
    //setup the collection view that holds the users card
    func setUpCardCollectionView() {
        viewProfileCollectionView.delegate = self
        viewProfileCollectionView.dataSource = self
        viewProfileCollectionView.register(UINib(nibName: "Card", bundle: nil), forCellWithReuseIdentifier: cellId)
    }
    
    //only one cell should be returned since your only viewing one users profile.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    //populate the card with the other users profile.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let quadCard = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! Card
        quadCard.setUp(user: self.otherUserProfile)
        
        
        //TODO: find a better solution for this where we can make the items from Card.swift clickable
        //moving sync arrow to front to be clickable
        quadCard.shadowOuterContainer.bringSubviewToFront(quadCard.cardContainer)
        quadCard.shadowOuterContainer.bringSubviewToFront(quadCard.cardContainer.back)
        quadCard.shadowOuterContainer.bringSubviewToFront(quadCard.cardContainer.front)
        quadCard.front.flipButton.addTarget(self, action: #selector(flipButtonClicked), for: .touchUpInside) //set on click listener for send message button
        quadCard.back.flipButton.addTarget(self, action: #selector(flipButtonClicked), for: .touchUpInside) //set on click listener for send message button

        self.cardClicked = quadCard
        
        
        
        return quadCard
    }
    
    //on click of the send hi message on back of card
    @objc func flipButtonClicked(_ sender: subclassedUIButton) {
        
        self.cardClicked!.flip()
        
    }
    
    
    //leave to main activity
    func leaveForMainActivity() {
        self.performSegue(withIdentifier: "unfriendToMain" , sender: self)
    }
    

    
}
