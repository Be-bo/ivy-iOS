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
    private var thisUserProfile = Dictionary<String, Any>()
    private let thisUserId = Auth.auth().currentUser!.uid
    var thisUniDomain = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startListeningToUserProfile()
    }
    
    private func startListeningToUserProfile(){
        baseDatabaseReference.collection("universities").document(thisUniDomain).collection("userprofiles").document(thisUserId).addSnapshotListener() { (docSnap, e) in
            if let e = e{
                print("Error obtaining user profile: \(e)")
            }else{
                if(docSnap?.exists ?? false && docSnap?.data() != nil){
                    self.thisUserProfile = (docSnap?.data())!
                    self.updateTabs()
                }
            }
        }
    }
    
    private func updateTabs(){
        guard let ventureCapitalists = viewControllers else{ 
            return
        }
        print("preping VCs")
        for nvc in ventureCapitalists {
            if let exploreNVC = nvc as? ExploreNavigationController{
                if let explore = exploreNVC.visibleViewController as? Explore{
                    explore.updateProfile(updatedProfile: thisUserProfile)
                }
            }
            if let boardNVC = nvc as? BoardNavigationViewController{
                if let board = boardNVC.visibleViewController as? Board{
                    board.updateProfile(updatedProfile: thisUserProfile)
                }
            }
            if let quadNVC = nvc as? QuadNavigationViewController{
                if let quad = quadNVC.visibleViewController as? Quad{
                    quad.updateProfile(updatedProfile: thisUserProfile)
                }
            }
            if let chatNVC = nvc as? ChatNavigationController{
                if let chat = chatNVC.visibleViewController as? Chat{
                    chat.updateProfile(updatedProfile: thisUserProfile)
                }            }
            if let profileNVC = nvc as? ProfileNavigationViewController{
                if let profile = profileNVC.visibleViewController as? Profile{
                    profile.updateProfile(updatedProfile: thisUserProfile)
                }
            }
        }
    }
    
}
