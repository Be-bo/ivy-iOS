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
    
    private let topicCommentCollectionIdentifier = "TopicCommentCollectionViewCell"
    @IBOutlet weak var commentCollectionView: UICollectionView!
    
    private var thisTopicRegistration:ListenerRegistration? = nil

    
    @IBOutlet weak var authorImageView: UIImageView!
    @IBOutlet weak var topicTextView: UITextField!
    @IBOutlet weak var textHeight: NSLayoutConstraint!
    
    
    
    // MARK: Base Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationBar()
        setUp()
    }
    
    
    private func setUpNavigationBar(){
    }
    
    private func setUp(){
        commentCollectionView.delegate = self
        commentCollectionView.dataSource = self
        commentCollectionView.register(UINib(nibName:topicCommentCollectionIdentifier, bundle: nil), forCellWithReuseIdentifier: topicCommentCollectionIdentifier)
        
        prepareTopic() //start loading the topic data
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
                    if let isAnony = self.thisTopic["is_anonymous"] as? Bool, let topicAuthorID = self.thisTopic["author_id"] as? String{
                        if (!isAnony){
                            self.baseStorageReference.child("userimages").child(topicAuthorID).child("preview.jpg").getData(maxSize: 5 * 1024 * 1024) { data, error in
                                if let error = error {
                                    print("error", error)
                                } else {
                                    self.authorImageView.image = UIImage(data: data!)
                                    let tapAuthorImage = UITapGestureRecognizer(target: self, action: #selector(self.tapAuthorImage))
                                    self.authorImageView.isUserInteractionEnabled = true
                                    self.authorImageView.addGestureRecognizer(tapAuthorImage)
                                    
                                    //TODO: set on click listener for more button of this screen
                                }
                            }
                        }
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
        topicComments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let commentCell = collectionView.dequeueReusableCell(withReuseIdentifier: topicCommentCollectionIdentifier, for: indexPath) as! TopicCommentCollectionViewCell
        
        
        //TODO: populate the topic cell with the title of the topic
        return commentCell
    }
    


}
