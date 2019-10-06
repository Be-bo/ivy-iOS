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
    var mediatorDelegate: SearchCellDelegator!
    
    var noResultsCounter = 0
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
    let progressWheel: UIActivityIndicatorView = {
        let ivyProgressWheel = UIActivityIndicatorView()
        ivyProgressWheel.color = UIColor.ivyGreen
        ivyProgressWheel.frame.size = CGSize(width: 50, height: 50)
        ivyProgressWheel.frame.origin = CGPoint(x: (UIScreen.main.bounds.width/2-25), y: (UIScreen.main.bounds.height/2-25))
        return ivyProgressWheel
    }()
    let noResultsLabel: StandardLabel = {
        let label = StandardLabel()
        label.text = "Couldn't find anything. Sorry. :-("
        label.frame.size = CGSize(width: UIScreen.main.bounds.width, height: 50)
        label.textAlignment = .center
        label.frame.origin = CGPoint(x: (UIScreen.main.bounds.width/2-label.frame.width/2), y: (UIScreen.main.bounds.height/2-label.frame.height/2))
        return label
    }()

    
    
    
    
    
    
    
    
    // MARK: Base Functions
    
    override init() {
        super.init()
        searchCollectionView.delegate = self
        searchCollectionView.dataSource = self
        searchCollectionView.register(UINib.init(nibName: "SearchCell", bundle: nil), forCellWithReuseIdentifier: searchCellId)
    }
    
    func triggerPanel(searchBar: UITextField, navBarHeight: CGFloat, thisUser: Dictionary<String, Any>, rulingVC: SearchCellDelegator){ //trigger an animation of a sliding panel from the bottom of the screen and add the necessary ui elems onto it programatically
        thisUserProfile = thisUser
        mediatorDelegate = rulingVC
        if let window = UIApplication.shared.keyWindow{
            
            //COLLECTION VIEW
            window.addSubview(searchCollectionView)
            let height: CGFloat = window.frame.height - searchBar.frame.origin.y - navBarHeight - searchBar.frame.size.height - UIApplication.shared.statusBarFrame.size.height - 10
            let y = window.frame.height - height
            searchCollectionView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: height)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.searchCollectionView.frame = CGRect(x: 0, y: y, width: self.searchCollectionView.frame.width, height: self.searchCollectionView.frame.height)
            }, completion: nil)
            
            //PROGRESS WHEEL
            window.addSubview(progressWheel)
            progressWheel.startAnimating()
            window.bringSubviewToFront(progressWheel)
            progressWheel.isHidden = true
            
            //NO RESULTS LABEL
            window.addSubview(noResultsLabel)
            window.bringSubviewToFront(noResultsLabel)
            noResultsLabel.isHidden = true
        }
    }
    
    
    @objc func panelDismiss(){ //hide the panel and its UI elements
        progressWheel.isHidden = true
        noResultsLabel.isHidden = true
        UIView.animate(withDuration: 0.5) {
            if let window = UIApplication.shared.keyWindow {
                self.searchCollectionView.frame = CGRect(x: 0, y: window.frame.height, width: self.searchCollectionView.frame.width, height: window.frame.height)
            }
        }
    }
    
    
    
    
    
    
    
    
    // MARK: Search Functions
    
    func search(hitJson: [String: Any]){ //run a single search query
        var userIds = Array<String>() //reset local lists with result ids
        var organizationIds = Array<String>()
        var eventIds = Array<String>()
        noResultsCounter = 0
        
        //parse JSON
        if let jsonResultsArray = hitJson["results"] as? Array<[String: Any]>{//results[0] is users, results[1] is organizations, results[2] is events
            //USERS
            if let usersHitsArray = jsonResultsArray[0]["hits"] as? Array<[String: Any]>{
                for i in 0..<usersHitsArray.count{
                    if let currentId = usersHitsArray[i]["id"] as? String{
                        userIds.append(currentId)
                    }
                }
            }
            
            //ORGANIZATIONS
            if let organizationHitsArray = jsonResultsArray[1]["hits"] as? Array<[String: Any]>{
                for i in 0..<organizationHitsArray.count{
                    if let currentId = organizationHitsArray[i]["id"] as? String{
                        organizationIds.append(currentId)
                    }
                }
            }
            
            //EVENTS
            if let eventHitsArray = jsonResultsArray[2]["hits"] as? Array<[String: Any]>{
                for i in 0..<eventHitsArray.count{
                    if let currentId = eventHitsArray[i]["id"] as? String{
                        eventIds.append(currentId)
                    }
                }
            }
        }
        
        
        //get searched data from Firestore based on ids
        if(userIds.count == 0 && organizationIds.count == 0 && eventIds.count == 0){
            progressWheel.isHidden = true
            noResultsLabel.isHidden = false
        }else{
            if let uniDomain = thisUserProfile["uni_domain"] as? String, let thisUserId = thisUserProfile["id"] as? String{ //check the required fields
            baseDatabaseReference.collection("universities").document(uniDomain).collection("userprofiles").document(thisUserId).collection("userlists").document("blocked_by").getDocument { (blockedBySnapshot, err) in //get this user's blocked by list
                    if(err == nil){
                        var blockedByList = Dictionary<String, Any>()
                        if(blockedBySnapshot?.exists ?? false){
                            blockedByList = blockedBySnapshot?.data() ?? Dictionary<String, Any>()
                        }
                        
                        //get the corresponding user objects
                        if(userIds.count > 0){
                            for i in 0..<userIds.count{
                                if(blockedByList[userIds[i]] == nil){ //if current id blocking this user don't do anything
                                    self.baseDatabaseReference.collection("universities").document(uniDomain).collection("userprofiles").document(userIds[i]).getDocument(completion: { (userSnapshot, err) in
                                        if(userSnapshot?.exists ?? false && userSnapshot?.data() != nil) && thisUserId != userSnapshot?.documentID{
                                            if var current = userSnapshot?.data() {
                                                current["search_type"] = "user" //set the type of the search result (so that we display the corresponding data in the collection view properly - see SearchCell.swift)
                                                self.all_results.append(current)
                                                self.searchCollectionView.reloadData()
                                                self.progressWheel.isHidden = true
                                            }
                                        }
                                        if(self.all_results.count < 1 && i >= userIds.count-1){ //if we've finished the last item of the query and there's no results increment the no results counter - i.e. if there's something that exists in Algolia but not in Firestore
                                            self.noResultsCounter += 1
                                            self.checkForNoResults() //and check if that's already happened 3 times (i.e. we've gone through all of the queries's last items and still have no results)
                                        }
                                    })
                                }
                            }
                        }else{
                            self.noResultsCounter += 1 //if there are no results to begin with
                            self.checkForNoResults()
                        }
                        
                        //get the corresponding organization objects
                        if(organizationIds.count > 0){
                            for i in 0..<organizationIds.count{
                                self.baseDatabaseReference.collection("organizations").document(organizationIds[i]).getDocument(completion: { (organizationSnapshot, err) in
                                    if(organizationSnapshot?.exists ?? false && organizationSnapshot?.data() != nil){
                                        if var current = organizationSnapshot?.data() {
                                            current["search_type"] = "organization"
                                            self.all_results.append(current)
                                            self.searchCollectionView.reloadData()
                                            self.progressWheel.isHidden = true
                                        }
                                    }
                                    if(self.all_results.count < 1 && i >= organizationIds.count-1){
                                        self.noResultsCounter += 1
                                        self.checkForNoResults()
                                    }
                                })
                            }
                        }else{
                            self.noResultsCounter += 1
                            self.checkForNoResults()
                        }
                        
                        //get the corresponding event objects
                        if(eventIds.count > 0){
                            for i in 0..<eventIds.count{
                                self.baseDatabaseReference.collection("universities").document(uniDomain).collection("events").document(eventIds[i]).getDocument(completion: { (eventSnapshot, err) in
                                    if(eventSnapshot?.exists ?? false && eventSnapshot?.data() != nil){
                                        if var current = eventSnapshot?.data() {
                                            current["search_type"] = "event"
                                            if let endTime = current["end_time"] as? Int64, endTime > Date().millisecondsSince1970{ //make sure the event isn't expired before we add it
                                                self.all_results.append(current)
                                                self.searchCollectionView.reloadData()
                                                self.progressWheel.isHidden = true
                                            }
                                        }
                                    }
                                    if(self.all_results.count < 1 && i >= eventIds.count-1){
                                        self.noResultsCounter += 1
                                        self.checkForNoResults()
                                    }
                                })
                            }
                        }else{
                            self.noResultsCounter += 1
                            self.checkForNoResults()
                        }
                    }
                }
            }
        }
    }
    
    func checkForNoResults(){ //check whether we actually got any tangible results across all search types
        if(noResultsCounter >= 3){ //if there's nothing to show -> display the no results label to get the user know and hide the progress wheel
            progressWheel.isHidden = true
            noResultsLabel.isHidden = false
        }
    }
    
    func resetSearchCollectionView(){
        all_results = Array<Dictionary<String, Any>>() //reset the collection view
        searchCollectionView.reloadData()
    }
    
    
    
    
    
    
    
    
    
    // MARK: collectionView functions
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return all_results.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: searchCellId, for: indexPath) as! SearchCell
        cell.delegate = self.mediatorDelegate //to make sure the delegator for triggering segues in Explore from SearchCells works
        cell.setUp(searchResult: all_results[indexPath.item])
        progressWheel.isHidden = true
        noResultsLabel.isHidden = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 66)
    }

}
