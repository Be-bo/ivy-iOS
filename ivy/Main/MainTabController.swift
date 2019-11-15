//
//  MainTabController.swift
//  ivy
//
//  Created by Robert on 2019-07-28.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class MainTabController: UITabBarController {
    
    private let baseDatabaseReference = Firestore.firestore()
    var thisUserProfile = Dictionary<String, Any>()
    var thisUserId = Auth.auth().currentUser!.uid
    var thisUniDomain = ""
    var userProfileListener:ListenerRegistration? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startListeningToUserProfile()
        self.selectedIndex = 1          //set selected index to be the explore tab on launch
    }
    
    private func startListeningToUserProfile(){
        //make sure the user is actually signed in and authenticated first to prevent the signout error
        Auth.auth().addStateDidChangeListener { (auth, user) in
                   if user != nil {
                    self.userProfileListener = self.baseDatabaseReference.collection("universities").document(self.thisUniDomain).collection("userprofiles").document(self.thisUserId).addSnapshotListener() { (docSnap, e) in
                        if let e = e{
                            print("Error obtaining user profile: \(e)")
                            PublicStaticMethodsAndData.createInfoDialog(titleText: "Error", infoText: "We couldn't get your user data, try restarting the app. :-(", context: self)
                            exit(0) //discouraged by Apple
                        }else{
                            if(docSnap?.exists ?? false && docSnap?.data() != nil){
                                self.thisUserProfile = (docSnap?.data())!
                                if let age = self.thisUserProfile["age"] as? Int64, let milliBirth = self.thisUserProfile["birth_time"] as? Int64{
                                    if PublicStaticMethodsAndData.calculateAge(millis: milliBirth) != age, let uni = self.thisUserProfile["uni_domain"] as? String, let id = self.thisUserProfile["id"] as? String{ //update age if there's a mismatch
                                        var merger = Dictionary<String, Any>()
                                        merger["age"] = PublicStaticMethodsAndData.calculateAge(millis: milliBirth)
                                        self.baseDatabaseReference.collection("universities").document(uni).collection("userprofiles").document(id).setData(merger, merge: true)
                                    }
                                }
                                self.updateTabs()
                                self.checkMessageNotification()
                            }else{
                                PublicStaticMethodsAndData.createInfoDialog(titleText: "Error", infoText: "Your user profile doesn't exist, please contact us.", context: self)
                                exit(0)
                            }
                        }
                    }
            } else { // user is not signed in so remove the attached listener and dont load any data
                    self.userProfileListener?.remove()
            }
        }
    }
    
    private func updateTabs(){
        guard let ventureCapitalists = viewControllers else{ 
            return
        }
        for nvc in ventureCapitalists {
            if let exploreNVC = nvc as? ExploreNavigationController{
                if let explore = exploreNVC.visibleViewController as? Explore{
                    explore.updateProfile(updatedProfile: thisUserProfile)
                }
            }
//            if let boardNVC = nvc as? BoardNavigationViewController{
//                if let board = boardNVC.visibleViewController as? Board{
//                    board.updateProfile(updatedProfile: thisUserProfile)
//                }
//            }
            if let quadNVC = nvc as? QuadNavigationViewController{
               if let quad = quadNVC.visibleViewController as? Quad{
                    quad.updateProfile(updatedProfile: thisUserProfile)
                }
            }
            if let chatNVC = nvc as? ChatNavigationController{
                if let chat = chatNVC.visibleViewController as? Chat{
                    chat.updateProfile(updatedProfile: thisUserProfile)
                }
            }
            if let profileNVC = nvc as? ProfileNavigationViewController{
                if let profile = profileNVC.visibleViewController as? Profile{
                    profile.updateProfile(updatedProfile: thisUserProfile)
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        userProfileListener?.remove() //stop listening to changes when the app quits or the user signs outs (i.e. the tab controller stops existing)
    }
    
    
    
    
    
    // MARK: Chat Notification Functions
    
    private func checkMessageNotification(){
        if let pendingMessages = thisUserProfile["pending_messages"] as? Bool, pendingMessages{
            tabBar.items![0].image = UIImage(named: "chat_notification")?.withRenderingMode(.alwaysOriginal)
        }else{
            tabBar.items![0].image = UIImage(named: "chat")
        }
    }
    
    private func updatePendingMessage(){
        if let uniDomain = thisUserProfile["uni_domain"] as? String, let thisUid = thisUserProfile["id"] as? String {
            self.tabBar.items![0].image = UIImage(named: "chat")
            var toMerge = Dictionary<String, Any>()
            toMerge["pending_messages"] = false
            baseDatabaseReference.collection("universities").document(uniDomain).collection("userprofiles").document(thisUid).setData(toMerge, merge: true)
        }
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item == self.tabBar.items?[0]{
            self.tabBar.items![0].image = UIImage(named: "chat")
            self.updatePendingMessage()
        }
        checkMessageNotification()
    }
}
