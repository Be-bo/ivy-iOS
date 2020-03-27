//
//  BoardTopic.swift
//  ivy-iOS
//
//  Created by paul dan on 2020-03-03.
//  Copyright © 2020 ivy social network. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage




class BoardTopic: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    //MARK: Variables and Constant
    public var thisUserProfile = Dictionary<String, Any>()
    private let baseDatabaseReference = Firestore.firestore()
    private let baseStorageReference = Storage.storage().reference()
    
    
    public var thisTopic = Dictionary<String, Any>()
    private var topicComments = [Dictionary<String, Any>]()
    private var firstLaunch = true
    
    private let topicHeaderCollectionIdentifier = "TopicHeaderCollectionViewCell"
    private let topicCommentCollectionIdentifier = "TopicCommentCollectionViewCell"
    private let topicAddCommentCollectionIdentifier = "TopicAddCommentCollectionViewCell"

    @IBOutlet weak var topicCollectionView: UICollectionView!
    
    private var thisTopicRegistration:ListenerRegistration? = nil

    private var topicHeaderAuthorImage:UIImage = UIImage()
    private var topicHeaderTitle:String = String()
    

    
    
    // MARK: Base Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationBar()
        setupCollectionViews()
        prepareTopic()
    }
    
    
    private func setUpNavigationBar(){
    }
    
    private func setupCollectionViews(){
        //https://stackoverflow.com/questions/14674986/uicollectionview-set-number-of-columns
        let columnLayout = ColumnFlowLayout(
            cellsPerRow: 1,
            minimumInteritemSpacing: 10,
            minimumLineSpacing: 10,
            sectionInset: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        )
        topicCollectionView.delegate = self
        topicCollectionView.dataSource = self
        topicCollectionView.collectionViewLayout = columnLayout
        topicCollectionView.contentInsetAdjustmentBehavior = .always
        topicCollectionView.register(UINib(nibName:topicHeaderCollectionIdentifier, bundle: nil), forCellWithReuseIdentifier: topicHeaderCollectionIdentifier)
        topicCollectionView.register(UINib(nibName:topicAddCommentCollectionIdentifier, bundle: nil), forCellWithReuseIdentifier: topicAddCommentCollectionIdentifier)
        topicCollectionView.register(UINib(nibName:topicCommentCollectionIdentifier, bundle: nil), forCellWithReuseIdentifier: topicCommentCollectionIdentifier)
    }
    
    private func setUp(){
//        addThisUserToLookingIds()
        
    }
    

    
    
    
    // MARK: Data Acquisition Methods
    func prepareTopic(){
        if let uniDomain = self.thisUserProfile["id"] as? String, let topicID = self.thisTopic["id"] as? String{
            thisTopicRegistration = self.baseDatabaseReference.collection("universities").document(uniDomain).collection("topics").document(topicID).addSnapshotListener({ (documentSnapshot, err) in
                guard documentSnapshot != nil else {
                    print("Error initializing in BoardTopic: \(err!)")
                    return
                }
                
                if let docData = documentSnapshot?.data(){
                    self.thisTopic = docData
                }
                
                if(self.firstLaunch){
                    self.firstLaunch = false
                    if let isAnony = self.thisTopic["is_anonymous"] as? Bool, let topicAuthorID = self.thisTopic["author_id"] as? String,
                        let topicTitle = self.thisTopic["text"] as? String{
                        
                        if (!isAnony){
                            self.baseStorageReference.child("userimages").child(topicAuthorID).child("preview.jpg").getData(maxSize: 5 * 1024 * 1024) { data, error in
                                if let error = error {
                                    print("error", error)
                                } else {
                                    self.topicHeaderAuthorImage = UIImage(data: data!)!
                                    
                                    //TODO: set on click listener for more button of this screen
                                    self.topicCollectionView.reloadData()
                                }
                            }
                        }
                        self.topicHeaderTitle = topicTitle //title there regard of anonymity. setup rest
                        self.setUp()
                    }
                    //TODO: set name of the topic regardless if anony or not
                    //TODO: setUp()
                }else{ //not first launch, only thing that needs to change is "people looking at" number
                    if let lookingIds = self.thisTopic["looking_ids"] as? Array<String>{
                        if (lookingIds.isEmpty){
                            //TODO: set how many people are looking at htis topic in the nav bar
                        }
                    }

                }
            })
        }
        if let uniDomain = self.thisUserProfile["uni_domain"] as? String, let thisTopicID = self.thisTopic["id"] as? String{
            self.baseDatabaseReference.collection("universities").document(uniDomain).collection("topics").document(thisTopicID).getDocument { (documentSnapshit, err) in
                }
        }
    }
    
    //Action
    @objc func tapAuthorImage() {
        
    }
    
    //MARK: Collection View Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        topicComments.count + 2 //plus 2 one for the topic header 1 for the ability to comment
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        //first one is just the topic header
        if (indexPath == IndexPath(item: 0, section: 0)){
            let cell: TopicHeaderCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: topicHeaderCollectionIdentifier, for: indexPath) as! TopicHeaderCollectionViewCell
            cell.authorImage.image = self.topicHeaderAuthorImage
            cell.authorTitle.text = self.topicHeaderTitle
            
//            let tapAuthorImage = UITapGestureRecognizer(target: self, action: #selector(self.tapAuthorImage))
//            self.tapAuthorImage.isUserInteractionEnabled = true
//            self.tapAuthorImage.addGestureRecognizer(tapAuthorImage)
                
            return cell
            
        }else if(indexPath == IndexPath(item: 1, section: 0)){ //second is the ability to add a comment yourslef
            let cell: TopicAddCommentCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: topicAddCommentCollectionIdentifier, for: indexPath) as! TopicAddCommentCollectionViewCell
            
            //add onclick listener for comment submission
            
            //add image to the person whos commenting (current user)
            if let thisUserID = self.thisUserProfile["id"] as? String{
                self.baseStorageReference.child("userimages").child(thisUserID).child("preview.jpg").getData(maxSize: 5 * 1024 * 1024) { data, error in
                    if let error = error {
                        print("error", error)
                    } else {
                        cell.addCommentAuthorImage.image = UIImage(data: data!)!
                        
                    }
                }
            }
            
            
            return cell
        }else{  //after 1st and second its jsut regular comments
            let cell: TopicCommentCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: topicCommentCollectionIdentifier, for: indexPath) as! TopicCommentCollectionViewCell
            return cell
        }
        
        
        
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellSize = CGSize(width: collectionView.frame.size.width, height: 140)  //as long as the collection view
        return cellSize
//        //first item will always be header so stretch to maximum screen length
//        if (indexPath == IndexPath(item: 0, section: 0)) {
//
//            let cellSize = CGSize(width: collectionView.frame.size.width, height: 140)  //as long as the collection view
//            return cellSize
//        }else{
//
//            let cellSize = CGSize(width: 100, height: 140)
//            return cellSize
//        }
    
    }
    


}
