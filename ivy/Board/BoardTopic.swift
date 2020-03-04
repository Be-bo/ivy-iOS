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
    private var fullTopic = Dictionary<String, Any>()
    public var topicID:String = ""
    private var topicComments = [Dictionary<String, Any>]()
    
    private let topicCommentCollectionIdentifier = "TopicCommentCollectionViewCell"
    @IBOutlet weak var commentCollectionView: UICollectionView!
    

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
        startLoadingData() //start loading the topic data
    }
    
    
    
    // MARK: Data Acquisition Methods
    func startLoadingData(){

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
