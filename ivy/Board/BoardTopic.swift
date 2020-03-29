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
    private var allTopicComments = [Dictionary<String, Any>]()
    private var imageAuthorID = ""
    private var firstLaunch = true
    private var firstCommentLoad:Bool = Bool()

    private let topicHeaderCollectionIdentifier = "TopicHeaderCollectionViewCell"
    private let topicCommentCollectionIdentifier = "TopicCommentCollectionViewCell"
    private let topicAddCommentCollectionIdentifier = "TopicAddCommentCollectionViewCell"

    @IBOutlet weak var topicCollectionView: UICollectionView!
    
    private var thisTopicRegistration:ListenerRegistration? = nil
    private var commentsRegistration:ListenerRegistration? = nil

    private var topicHeaderAuthorImage:UIImage = UIImage()
    private var topicHeaderTitle:String = String()
    
    
    
    
    // MARK: Base Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()     //extension defined in extensions for closing the keyboard
        setupCollectionViews()
        prepareTopic()

    

    }
    
    
    //TODO: write the on resume case incase they close the app while still in the board. detatching listeners and what not
    override func viewDidDisappear(_ animated: Bool) {
        detatchListeners()

    }
    
    
    private func setUpNavigationBar(){
        
        let moreButton = UIButton(type: .custom)
        moreButton.frame = CGRect(x: 0.0, y: 0.0, width: 35, height: 35)
        moreButton.setImage(UIImage(named:"more"), for: .normal)
        moreButton.addTarget(self, action: #selector(self.moreClicked), for: .touchUpInside)
        let moreButtonItem = UIBarButtonItem(customView: moreButton)
        let currWidth = moreButtonItem.customView?.widthAnchor.constraint(equalToConstant: 35)
        currWidth?.isActive = true
        let currHeight = moreButtonItem.customView?.heightAnchor.constraint(equalToConstant: 35)
        currHeight?.isActive = true
        
        let groupButton = UIButton(type: .custom)
        groupButton.frame = CGRect(x: 0.0, y: 0.0, width: 35, height: 35)
        groupButton.setImage(UIImage(named:"group"), for: .normal)
        groupButton.isEnabled = false
        let groupButtonItem = UIBarButtonItem(customView: groupButton)
        let currGroupWidth = groupButtonItem.customView?.widthAnchor.constraint(equalToConstant: 35)
        currGroupWidth?.isActive = true
        let currGroupHeight = groupButtonItem.customView?.heightAnchor.constraint(equalToConstant: 35)
        currGroupHeight?.isActive = true
        
        //TODO figure out how to customize the nav bar to have the group and text and be accessbile
        
//        self.navigationItem.leftBarButtonItem = groupButtonItem
        self.navigationItem.rightBarButtonItem = moreButtonItem

        setUp()

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
        addThisUserToLookingIds()
        setUpCommentsListener()
    }
    
    private func setUpCommentsListener(){
        self.firstCommentLoad = true
        //TODO: reload data here?
        if let uniDomain = self.thisUserProfile["uni_domain"] as? String, let thisTopicID = self.thisTopic["id"] as? String {
            self.commentsRegistration = self.baseDatabaseReference.collection("universities").document(uniDomain).collection("topics").document(thisTopicID).collection("comments").order(by: "creation_millis", descending: true).addSnapshotListener({ (querySnapshot, err) in
           
                guard let snapshot = querySnapshot else {
                    print("Error initializing comments in Board: \(err!)")
                    return
                }
                
                snapshot.documentChanges.forEach { diff in
                    if (diff.type == .added) {
                        let newComment =  diff.document.data()
                        //TODO: figure out why we get duplicates of all the comments on the topic
                        if(self.firstCommentLoad){
                            self.allTopicComments.append(newComment)
                            self.topicCollectionView.reloadData()
                        }else{
                            self.allTopicComments.insert(newComment, at: 0)
                            self.topicCollectionView.reloadData()
                        }
                    }
                    
                    if (diff.type == .modified) {
                        //let modifiedComment = diff.document.data()
                        //TODO: if they can edit their comment then add stuff here
                        return
                    }
                    if (diff.type == .removed) {
                        //let removedComment = diff.document.data()
                        //TODO: if they can remove their comment then add stuff here
                        return
                    }
                }

                self.firstCommentLoad = false
                
            })

        }
        
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
                                    self.setUpNavigationBar()   //set on click listener for more button of this screen
                                    self.topicCollectionView.reloadData()
                                }
                            }
                        }
                        self.topicHeaderTitle = topicTitle //title there regard of anonymity. setup rest
                        self.setUpNavigationBar()

                    }

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
            self.baseDatabaseReference.collection("universities").document(uniDomain).collection("topics").document(thisTopicID).getDocument { (documentSnapshot, err) in
                }
        }
    }
    

    
    //MARK: Collection View Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("count: ", allTopicComments.count)
        return allTopicComments.count + 2 //plus 2 one for the topic header 1 for the ability to comment
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        //first one is just the topic header
        if (indexPath == IndexPath(item: 0, section: 0)){
            
            let cell: TopicHeaderCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: topicHeaderCollectionIdentifier, for: indexPath) as! TopicHeaderCollectionViewCell
            
            cell.authorImage.image = self.topicHeaderAuthorImage
            cell.authorImage.maskCircle(anyImage: cell.authorImage.image!)          //extension used
            cell.authorTitle.text = self.topicHeaderTitle
            
            if let thisUserID = self.thisUserProfile["id"] as? String, let thisTopicAuthorID = self.thisTopic["author_id"] as? String{
                //attach on click listener if the topic isn't authored by you
                if !(thisUserID == thisTopicAuthorID){
                    //extension function - adds Tap to each cell -  executes code in the brackets when the cell imageclicked
                    cell.authorImage.addTapGestureRecognizer {
                        self.imageAuthorID = thisTopicAuthorID
                        self.performSegue(withIdentifier: "topicToProfile" , sender: self) //pass data over to
                    }
                }
            }
            
            return cell
        }else if(indexPath == IndexPath(item: 1, section: 0)){ //second is the ability to add a comment yourslef
            
            let cell: TopicAddCommentCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: topicAddCommentCollectionIdentifier, for: indexPath) as! TopicAddCommentCollectionViewCell
            cell.styleCell(cell: cell)  //extension
                        
            //add image to the person whos commenting (current user)
            if let thisUserID = self.thisUserProfile["id"] as? String{
                self.baseStorageReference.child("userimages").child(thisUserID).child("preview.jpg").getData(maxSize: 5 * 1024 * 1024) { data, error in
                    if let error = error {
                        print("error", error)
                    } else {
                        cell.addCommentAuthorImage.image = UIImage(data: data!)!
                        cell.addCommentAuthorImage.maskCircle(anyImage: cell.addCommentAuthorImage.image!)          //extension used
                        
                        let tapSubmitComment = UITapGestureRecognizer(target: self, action: #selector(self.postComment))
                        cell.addCommentSubmitButton.addGestureRecognizer(tapSubmitComment)
                    }
                }
            }
            
            return cell
        }else{  //after 1st and second its jsut regular comments
            
            let cell: TopicCommentCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: topicCommentCollectionIdentifier, for: indexPath) as! TopicCommentCollectionViewCell
            let index = indexPath.item - 2 // -2 since its first two are taken always
            let comment = self.allTopicComments[index]
            
            cell.styleCell(cell: cell)  //extension
            populateCommentCell(cell:cell, comment:comment, index:index)

            return cell
        }
    }
    
    func populateCommentCell(cell: TopicCommentCollectionViewCell, comment: Dictionary<String,Any>, index:Int){
        if let commentText = comment["text"] as? String, let commentAuthorID = comment["author_id"] as? String,
        let commentAuthorFirst = comment["first_name"] as? String, let commentAuthorLast = comment["last_name"] as? String,
        let thisUserID = self.thisUserProfile["id"] as? String{
            
            self.baseStorageReference.child("userimages").child(commentAuthorID).child("preview.jpg").getData(maxSize: 5 * 1024 * 1024) { data, error in
                if let error = error {
                    print("error", error)
                } else {
                    cell.commentAuthorImageView.image = UIImage(data: data!)!
                    cell.commentAuthorImageView.maskCircle(anyImage: cell.commentAuthorImageView.image!)          //extension used
                    
                    cell.commentText.text = commentText
                    cell.commentAuthorName.text = commentAuthorFirst + " " + commentAuthorLast
                    
                    //attach on click listener if its not your profile image
                    if !(thisUserID == commentAuthorID){
                        //extension function - adds Tap to each cell -  executes code in the brackets when the cell imageclicked
                        cell.commentAuthorImageView.addTapGestureRecognizer {
                            self.imageAuthorID = commentAuthorID
                            self.performSegue(withIdentifier: "topicToProfile" , sender: self) //pass data over to
                        }
                    }
                }
            }
        }
    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellSize = CGSize(width: collectionView.frame.size.width - 20, height: 140)  //as long as the collection view
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
    
    
    
    // MARK: Support Functions
    
    private func detatchListeners(){
        if let thisUserUniDomain = self.thisUserProfile["uni_domain"] as? String, let topicID = self.thisTopic["id"] as? String, let thisUserID = self.thisUserProfile["id"] as? String{
            self.baseDatabaseReference.collection("universities").document(thisUserUniDomain).collection("topics").document(topicID).updateData(["looking_ids" : FieldValue.arrayRemove([thisUserID])])
        }
        if(thisTopicRegistration != nil){
            print("remove lsitener for topic")
            thisTopicRegistration?.remove()
        }
        if(commentsRegistration != nil){
            print("remove lsitener for comments")
            commentsRegistration?.remove()
        }
        
    }

    private func addThisUserToLookingIds(){
        if let thisUserUniDomain = self.thisUserProfile["uni_domain"] as? String, let topicID = self.thisTopic["id"] as? String, let thisUserID = self.thisUserProfile["id"] as? String{
            self.baseDatabaseReference.collection("universities").document(thisUserUniDomain).collection("topics").document(topicID).updateData(["looking_ids" : FieldValue.arrayUnion([thisUserID])])
        }
    }
    
    //TODO get rid of this stuff when we can have the actions on the back of the card appear
    @objc func showActions() {
        let actionSheet = UIAlertController(title: "Actions", message: .none, preferredStyle: .actionSheet)
        actionSheet.view.tintColor = UIColor.ivyGreen
        
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        //ADDING ACTIONS TO THE ACTION SHEET
        actionSheet.addAction(UIAlertAction(title: "Report", style: .default, handler: self.reportTopic))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @objc func moreClicked(){
        showActions()
    }
    
    @objc func reportTopic(alert: UIAlertAction!){
        var report = Dictionary<String, Any>()
        
        
        report["reportee"] = self.thisUserProfile["id"] as! String
        report["report_type"] = "topic"
        report["target"] = self.thisTopic["id"] as? String
        report["time"] = Date().millisecondsSince1970
        let reportId = self.baseDatabaseReference.collection("reports").document().documentID   //create unique id for this document
        report["id"] = reportId
        //TODO: change self.card clicked to be the id of that person from the card
        self.baseDatabaseReference.collection("reports").whereField("reportee", isEqualTo: self.thisUserProfile["id"] as! String).whereField("target", isEqualTo: self.thisTopic["id"] as? String).addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                if(!querySnapshot!.isEmpty){
                    PublicStaticMethodsAndData.createInfoDialog(titleText: "Invalid Action", infoText: "You have already reported this topic.", context: self)
                }else{
                    self.baseDatabaseReference.collection("reports").document(reportId).setData(report)
                    PublicStaticMethodsAndData.createInfoDialog(titleText: "Success", infoText: "The topic has been reported.", context: self)
                }
            }
        }
    }
    
    @objc func postComment(){
        if let commentCell = (self.topicCollectionView.cellForItem(at: IndexPath(item: 1, section: 0)) as? TopicAddCommentCollectionViewCell),
            let currentInput = commentCell.addCommentTextField.text,
            let thisUserID = self.thisUserProfile["id"] as? String,
            let thisUserFirst = self.thisUserProfile["first_name"] as? String,
            let thisUserLast = self.thisUserProfile["last_name"] as? String,
            let thisUserUniDomain = self.thisUserProfile["uni_domain"] as? String{
            let thisTopicID = self.thisTopic["id"] as? String
            
            if(currentInput.count > 0){
                var newComment:Dictionary<String,Any> = Dictionary<String,Any>()
                newComment["id"] = NSUUID().uuidString
                newComment["author_id"] = thisUserID
                newComment["first_name"] = thisUserFirst
                newComment["last_name"] = thisUserLast
                newComment["creation_millis"] = Date().millisecondsSince1970
                newComment["is_anonymous"] = false
                newComment["text"] = currentInput
                newComment["uni_domain"] = thisUserUniDomain
                newComment["topic_id"] = thisTopicID
                //TODO: bar interaction?
                if let newCommentID = newComment["id"] as? String, let commentingIDs = self.thisTopic["commenting_ids"] as? [String]{
                    self.baseDatabaseReference.collection("universities").document(thisUserUniDomain).collection("topics").document(thisTopicID!).collection("comments").document(newCommentID).setData(newComment) { (err) in
                        
                        if let err = err{
                            print("Error pushing comment in topic: \(err)")
                        }else{
                            commentCell.addCommentTextField.text = ""   //clear the text
                            self.dismissKeyboard()
                            commentCell.addCommentTextField.endEditing(true)
                            if(!commentingIDs.contains(thisUserID)){
                                self.baseDatabaseReference.collection("universities").document(thisUserUniDomain).collection("topics").document(thisTopicID!).updateData(["commenting_ids" : FieldValue.arrayUnion([thisUserID])])
                            }
                        }
                        //TODO: re-allow interaction?
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //called every single time a segway is called
        if(segue.identifier == "topicToProfile"){
            let vc = segue.destination as! ViewFullProfileActivity
            vc.thisUserProfile = self.thisUserProfile
            vc.otherUserID = self.imageAuthorID
        }
    }
    


}

