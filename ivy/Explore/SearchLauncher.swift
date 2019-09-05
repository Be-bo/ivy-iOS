//
//  SearchLauncher.swift
//  ivy
//
//  Created by Robert on 2019-09-04.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import UIKit
import Firebase

class SearchLauncher: NSObject, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    
    // MARK: vars and constants
    
    let baseDatabaseReference = Firestore.firestore()
    let baseStorageReference = Storage.storage().reference()
    var thisUserProfile = Dictionary<String, Any>()
    
    var all_results = Array<Dictionary<String, Any>>()
    let searchCellId = "SearchCollectionCell"
    let searchCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.isPagingEnabled = true
        return cv
    }()
    
    
    
    
    // MARK: Base Functions
    
    override init() {
        super.init()
        searchCollectionView.delegate = self
        searchCollectionView.dataSource = self
        searchCollectionView.register(UINib.init(nibName: "SearchCell", bundle: nil), forCellWithReuseIdentifier: searchCellId)
    }
    
    func triggerPanel(searchBar: UITextField, navBarHeight: CGFloat, thisUser: Dictionary<String, Any>){
        thisUserProfile = thisUser
        if let window = UIApplication.shared.keyWindow{
            window.addSubview(searchCollectionView)
            let height: CGFloat = window.frame.height - searchBar.frame.origin.y - navBarHeight - searchBar.frame.size.height - UIApplication.shared.statusBarFrame.size.height - 10
            let y = window.frame.height - height
            searchCollectionView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: height)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.searchCollectionView.frame = CGRect(x: 0, y: y, width: self.searchCollectionView.frame.width, height: self.searchCollectionView.frame.height)
            }, completion: nil)
        }
    }
    
    
    @objc func panelDismiss(){
        UIView.animate(withDuration: 0.5) {
            if let window = UIApplication.shared.keyWindow {
                self.searchCollectionView.frame = CGRect(x: 0, y: window.frame.height, width: self.searchCollectionView.frame.width, height: window.frame.height)
            }
        }
    }
    
    
    
    
    // MARK: Search Functions
    
    func search(hitJson: [String: Any]){
        var userIds = Array<String>()
        var organizationIds = Array<String>()
        var eventIds = Array<String>()
        
        //parse JSON
        if let jsonResultsArray = hitJson["results"] as? Array<[String: Any]>{//results[0] is users, results[1] is organizations, results[2] is events
            //USERS
            if let usersHitsArray = jsonResultsArray[0]["hits"] as? Array<[String: Any]>{
                for i in 0...usersHitsArray.count{
                    if let currentId = usersHitsArray[i]["id"] as? String{
                        userIds.append(currentId)
                    }
                }
            }
            
            //ORGANIZATIONS
            if let organizationHitsArray = jsonResultsArray[0]["hits"] as? Array<[String: Any]>{
                for i in 0...organizationHitsArray.count{
                    if let currentId = organizationHitsArray[i]["id"] as? String{
                        userIds.append(currentId)
                    }
                }
            }
            
            //EVENTS
            if let eventHitsArray = jsonResultsArray[0]["hits"] as? Array<[String: Any]>{
                for i in 0...eventHitsArray.count{
                    if let currentId = eventHitsArray[i]["id"] as? String{
                        userIds.append(currentId)
                    }
                }
            }
        }
        
        
        if(userIds.count == 0 && organizationIds.count == 0 && eventIds.count == 0){
            //TODO: convey in the UI
        }else{
            if let uniDomain = thisUserProfile["uni_domain"] as? String, let thisUserId = thisUserProfile["id"] as? String{ //check the required fields
            baseDatabaseReference.collection("universities").document(uniDomain).collection("userprofiles").document(thisUserId).collection("userlists").document("blocked_by").getDocument { (blockedBySnapshot, err) in //get this user's blocked by list
                    if(err == nil){
                        var blockedByList = Dictionary<String, Any>()
                        if(blockedBySnapshot?.exists ?? false){
                            blockedByList = blockedBySnapshot?.data() ?? Dictionary<String, Any>()
                        }
                        
                        //get the corresponding user objects
                        for i in 0...userIds.count{
                            if(blockedByList[userIds[i]] == nil){ //if current id blocking this user don't do anything
                            self.baseDatabaseReference.collection("universities").document(uniDomain).collection("userprofiles").document(userIds[i]).getDocument(completion: { (userSnapshot, err) in
                                    if(userSnapshot?.exists ?? false && userSnapshot?.data() != nil){
                                        if var current = userSnapshot?.data() {
                                            current["search_type"] = "user"
                                            self.all_results.append(current)
                                            self.searchCollectionView.reloadData()
                                        }
                                    }
                                })
                            }
                        }
                        
                        //get the corresponding organization objects
                        for i in 0...organizationIds.count{
                            self.baseDatabaseReference.collection("organizations").document(organizationIds[i]).getDocument(completion: { (organizationSnapshot, err) in
                                if(organizationSnapshot?.exists ?? false && organizationSnapshot?.data() != nil){
                                    if var current = organizationSnapshot?.data() {
                                        current["search_type"] = "organization"
                                        self.all_results.append(current)
                                        self.searchCollectionView.reloadData()
                                    }
                                }
                            })
                        }
                        
                        //get the corresponding event objects
                        for i in 0...eventIds.count{
                            self.baseDatabaseReference.collection("universities").document(uniDomain).collection("events").document(eventIds[i]).getDocument(completion: { (eventSnapshot, err) in
                                if(eventSnapshot?.exists ?? false && eventSnapshot?.data() != nil){
                                    if var current = eventSnapshot?.data() {
                                        current["search_type"] = "event"
                                        self.all_results.append(current)
                                        self.searchCollectionView.reloadData()
                                    }
                                }
                            })
                        }
                    }
                }
            }
        }
        
    }
    
    
    
    
    
    // MARK: collectionView functions
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: searchCellId, for: indexPath) as! SearchCell
//        cell.configure(with: data[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 100)
    }
}
