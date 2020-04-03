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




class BoardTopic: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextViewDelegate{
    
    
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
    private let dividerCellIdentifier = "DividerCell"
    
    @IBOutlet weak var topicCollectionView: UICollectionView!
    
    private var thisTopicRegistration:ListenerRegistration? = nil
    private var commentsRegistration:ListenerRegistration? = nil
    
    private var topicHeaderAuthorImage:UIImage = UIImage()
    private var topicHeaderTitle:String = String()
    private var addCommentCell: TopicAddCommentCollectionViewCell?
    private var addCommentCellHeight: CGFloat = 76
    
    
    
    
    
    
    
    
    
    
    
    // MARK: Base Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()     //extension defined in extensions for closing the keyboard
        setupCollectionViews()
        setUp()
        NotificationCenter.default.addObserver(self, selector: #selector(setUp), name: UIApplication.willEnterForegroundNotification, object: nil) //add a listener to the app to call refresh inside of this VC when the app goes from background to foreground (is maximized)
        NotificationCenter.default.addObserver(self, selector: #selector(detachListeners), name: UIApplication.didEnterBackgroundNotification, object: nil) //when the app enters background/is killed remove the user from looking ids and detach the comment listener
    }
    
    override func viewDidDisappear(_ animated: Bool) { //if user goes back and dismissed the VC
        detachListeners()
    }
    

    
    private func setUpNavigationBar(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Actions", style: .plain, target: self, action: #selector(moreClicked))
        let peopleViewingView = PeopleLookingNavBarView.createMyClassView()
        self.navigationItem.titleView = peopleViewingView
    }
    
    private func setupCollectionViews(){
        //https://stackoverflow.com/questions/14674986/uicollectionview-set-number-of-columns
        let columnLayout = ColumnFlowLayout(
            cellsPerRow: 1,
            minimumInteritemSpacing: 10,
            minimumLineSpacing: 10,
            sectionInset: UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        )
        topicCollectionView.delegate = self
        topicCollectionView.dataSource = self
        topicCollectionView.collectionViewLayout = columnLayout
        topicCollectionView.contentInsetAdjustmentBehavior = .always
        topicCollectionView.register(UINib(nibName:topicHeaderCollectionIdentifier, bundle: nil), forCellWithReuseIdentifier: topicHeaderCollectionIdentifier)
        topicCollectionView.register(UINib(nibName:topicAddCommentCollectionIdentifier, bundle: nil), forCellWithReuseIdentifier: topicAddCommentCollectionIdentifier)
        topicCollectionView.register(UINib(nibName:topicCommentCollectionIdentifier, bundle: nil), forCellWithReuseIdentifier: topicCommentCollectionIdentifier)
        topicCollectionView.register(UINib(nibName: dividerCellIdentifier, bundle: nil), forCellWithReuseIdentifier: dividerCellIdentifier)
    }
    
    @objc private func setUp(){
        addThisUserToLookingIds()
        setUpCommentsListener()
    }
    
    func barInteraction(){ //disable user interaction and start loading animation (rotating the ivy logo)
        self.view.isUserInteractionEnabled = false
    }
    
    func allowInteraction(){ //enable interaction again
        self.view.isUserInteractionEnabled = true
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: Add Comment Functions
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if addCommentCell != nil{
            topicCollectionView.scrollToItem(at: IndexPath(item: 1, section: 0), at: .top, animated: true)
            if(addCommentCell!.addCommentTextView.text == "Add a comment"){
                addCommentCell!.addCommentTextView.textColor = UIColor.black
                addCommentCell!.addCommentTextView.text = ""
            }
            addCommentCell!.showButton()
            checkAndAdjustHeight()
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if addCommentCell != nil{
            checkAndAdjustHeight()
        }
    }
    
    func checkAndAdjustHeight(){
        if addCommentCell != nil{
            let newTextViewHeight = PublicStaticMethodsAndData.getHeight(for: addCommentCell!.addCommentTextView.text+"H", with: UIFont(name: "Cordia New", size: 25)!, width: addCommentCell!.addCommentTextView.layer.frame.width)
            let newHeight = newTextViewHeight + 24 + addCommentCell!.buttonHeightConstraint.constant + 8
            if(newHeight != addCommentCell!.layer.frame.height){ //don't wanna do it all the time unnecessarily
                if (newHeight < 76){
                    addCommentCellHeight = 76
                }else{
                    addCommentCellHeight = newHeight
                }
                addCommentCell!.textViewHeightConstraint.constant = newTextViewHeight
                topicCollectionView.collectionViewLayout.invalidateLayout()
            }
        }
    }
    
    func resetLayout(){
        if addCommentCell != nil{
            addCommentCell!.addCommentTextView.endEditing(true)
            addCommentCell!.buttonHeightConstraint.constant = 0
            addCommentCell!.addCommentSubmitButton.isEnabled = false
            addCommentCell!.addCommentSubmitButton.isHidden = true
            addCommentCell!.addCommentTextView.text = ""
            checkAndAdjustHeight()
        }
    }
    
    @objc func postComment(){
        if let commentCell = (self.topicCollectionView.cellForItem(at: IndexPath(item: 1, section: 0)) as? TopicAddCommentCollectionViewCell),
            let currentInput = commentCell.addCommentTextView.text,
            let thisUserID = self.thisUserProfile["id"] as? String,
            let thisUserFirst = self.thisUserProfile["first_name"] as? String,
            let thisUserLast = self.thisUserProfile["last_name"] as? String,
            let thisUserUniDomain = self.thisUserProfile["uni_domain"] as? String,
            let thisTopicID = self.thisTopic["id"] as? String{

            if(currentInput.count > 0){
                addCommentCell?.addCommentSubmitButton.isEnabled = false
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
                if let newCommentID = newComment["id"] as? String, let commentingIDs = self.thisTopic["commenting_ids"] as? [String]{
                    self.baseDatabaseReference.collection("universities").document(thisUserUniDomain).collection("topics").document(thisTopicID).collection("comments").document(newCommentID).setData(newComment) { (err) in
                        if let err = err{
                            print("Error pushing comment in topic: \(err)")
                        }else{
                            self.resetLayout()
                            if(!commentingIDs.contains(thisUserID)){
                                self.baseDatabaseReference.collection("universities").document(thisUserUniDomain).collection("topics").document(thisTopicID).updateData(["commenting_ids" : FieldValue.arrayUnion([thisUserID])])
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    
    
    
    
    
    
    
    // MARK: Data Acquisition Methods
    
    func prepareTopic(){
        if let uniDomain = self.thisUserProfile["uni_domain"] as? String, let topicID = self.thisTopic["id"] as? String{
            thisTopicRegistration = self.baseDatabaseReference.collection("universities").document(uniDomain).collection("topics").document(topicID).addSnapshotListener(){ (documentSnapshot, err) in
                                
                guard documentSnapshot != nil else {
                    print("Error initializing in BoardTopic: \(err!)")
                    return
                }
                
                if let docData = documentSnapshot?.data(){
                    self.thisTopic = docData
                }

                if(self.firstLaunch){
                    self.firstLaunch = false
                    self.setUpNavigationBar()
                    if let isAnony = self.thisTopic["is_anonymous"] as? Bool, let topicAuthorID = self.thisTopic["author_id"] as? String,
                        let topicTitle = self.thisTopic["text"] as? String, let topicId = self.thisTopic["id"] as? String{
                        self.topicHeaderTitle = topicTitle
                        
                        if(topicId == "oftheday"){
                            self.topicHeaderAuthorImage = UIImage(named: "ivy_logo")!
                            self.topicCollectionView.reloadData()
                        }else{
                            if (!isAnony){
                                self.baseStorageReference.child("userimages").child(topicAuthorID).child("preview.jpg").getData(maxSize: 5 * 1024 * 1024) { data, error in
                                    if let error = error {
                                        print("error", error)
                                    } else {
                                        self.topicHeaderAuthorImage = UIImage(data: data!)!
                                        self.topicCollectionView.reloadData()
                                    }
                                }
                            }else{
                                self.topicHeaderAuthorImage = UIImage(named: "quad_placeholder")!
                                self.topicCollectionView.reloadData()
                            }
                        }
                    }
                }
                
                if let lookingIds = self.thisTopic["looking_ids"] as? [String]{
                    if (!lookingIds.isEmpty){
                        (self.navigationItem.titleView as! PeopleLookingNavBarView).updateCount(count: String(lookingIds.count))    //PeopleLookingNavBarView.swift
                    }
                }
            }
        }
    }
    
    private func setUpCommentsListener(){
        self.firstCommentLoad = true
        if let uniDomain = self.thisUserProfile["uni_domain"] as? String, let thisTopicID = self.thisTopic["id"] as? String {
            self.commentsRegistration = self.baseDatabaseReference.collection("universities").document(uniDomain).collection("topics").document(thisTopicID).collection("comments").order(by: "creation_millis", descending: true).addSnapshotListener({ (querySnapshot, err) in
                
                guard let snapshot = querySnapshot else {
                    print("Error initializing comments in Board: \(err!)")
                    return
                }
                
                snapshot.documentChanges.forEach { diff in
                    if (diff.type == .added) {
                        let newComment =  diff.document.data()
                        var dontAdd = self.allTopicComments.contains(where: { (comment) -> Bool in //first check against all existing comments to make sure the comment hasn't been added in the past
                            if let newCommentId = newComment["id"] as? String, let currentlyCheckingId = comment["id"] as? String, newCommentId == currentlyCheckingId{ //if it has (id match) return true and do not even checking for adding
                                return true
                            }else{ //if there's no id match return false
                                return false
                            }
                        })
                        
                        if(self.allTopicComments.count < 1 || dontAdd == false){
                            if(self.firstCommentLoad){
                                self.allTopicComments.append(newComment)
                                self.topicCollectionView.reloadData()
                            }else{
                                self.allTopicComments.insert(newComment, at: 0)
                                self.topicCollectionView.reloadData()
                            }
                        }
                    }
                    
                    if (diff.type == .modified) {
                        //let modifiedComment = diff.document.data()
                        //TODO: if they can edit their comment then add stuff here
                        return
                    }
                    if (diff.type == .removed) {
                        let removedComment = diff.document.data()
                        let optionalIndex = self.allTopicComments.firstIndex { (comment) -> Bool in
                            if let removedCommentId = removedComment["id"] as? String, let currentlyCheckingId = comment["id"] as? String, removedCommentId == currentlyCheckingId{
                                return true
                            }else{
                                return false
                            }
                        }
                        if let posIndex = optionalIndex {
                            self.allTopicComments.remove(at: posIndex)
                            self.topicCollectionView.reloadData()
                        }
                        return
                    }
                }
                self.firstCommentLoad = false
            })
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //MARK: Collection View Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allTopicComments.count + 3 //plus 3 for the first special cells (header, add comment layer, divider)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (indexPath.item == 0){ //header
            let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: topicHeaderCollectionIdentifier, for: indexPath) as! TopicHeaderCollectionViewCell
            cell.authorImage.image = self.topicHeaderAuthorImage
            cell.authorImage.maskCircle(anyImage: cell.authorImage.image!) //extension used
            cell.authorTitle.text = self.topicHeaderTitle
            if let thisUserID = self.thisUserProfile["id"] as? String, let thisTopicAuthorID = self.thisTopic["author_id"] as? String, let isAnon = thisTopic["is_anonymous"] as? Bool, let thisTopicId = thisTopic["id"] as? String, thisTopicId != "oftheday"{
                if(thisUserID != thisTopicAuthorID && !isAnon){ //attach on click listener if the topic isn't authored by you and it's not anonymous
                    cell.authorImage.addTapGestureRecognizer { //extension function - adds Tap to each cell -  executes code in the brackets when the cell imageclicked
                        self.imageAuthorID = thisTopicAuthorID
                        self.performSegue(withIdentifier: "topicToProfile" , sender: self) //pass data over to
                    }
                }
            }
            return cell
            
        }else if(indexPath.item == 1){ //add comment layer
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: topicAddCommentCollectionIdentifier, for: indexPath) as! TopicAddCommentCollectionViewCell
            cell.styleCell(cell: cell)
            if let thisUserID = self.thisUserProfile["id"] as? String{ //add image to the person whos commenting (current user)
                self.baseStorageReference.child("userimages").child(thisUserID).child("preview.jpg").getData(maxSize: 5 * 1024 * 1024) { data, error in
                    if let error = error {
                        print("error", error)
                    } else {
                        cell.addCommentAuthorImage.image = UIImage(data: data!)!
                        cell.addCommentAuthorImage.maskCircle(anyImage: cell.addCommentAuthorImage.image!)
                        self.addCommentCell = cell //set up for later usage
                        self.addCommentCell?.addCommentTextView.delegate = self
                        let tapSubmitComment = UITapGestureRecognizer(target: self, action: #selector(self.postComment))
                        cell.addCommentSubmitButton.addGestureRecognizer(tapSubmitComment)
                    }
                }
            }
            return cell
            
        }else if (indexPath.item == 2){ //divider cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: dividerCellIdentifier, for: indexPath) as! DividerCell
            return cell
            
        }else{ //the actual comment
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: topicCommentCollectionIdentifier, for: indexPath) as! TopicCommentCollectionViewCell
            cell.styleCell(cell: cell)
            let comment = self.allTopicComments[indexPath.item - 3]
            populateCommentCell(cell:cell, comment:comment, index: indexPath.item - 3)
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
                    cell.commentLabel .text = commentText
                    cell.commentAuthorName.text = commentAuthorFirst + " " + commentAuthorLast
                    cell.commentAuthorImageView.addTapGestureRecognizer {
                        if !(thisUserID == commentAuthorID){
                            self.imageAuthorID = commentAuthorID
                            self.performSegue(withIdentifier: "topicToProfile" , sender: self) //pass data over to
                        }
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(indexPath.item == 0){ //header
            if let topicText = self.thisTopic["text"] as? String{
                let labelHeight = PublicStaticMethodsAndData.getHeight(for: topicText, with: UIFont(name: "Cordia New", size: 25)!, width: collectionView.frame.size.width - 20 - 84)
                var height = labelHeight + 16
                if(height < 76){
                    height = 76
                }
                let cellSize = CGSize(width: collectionView.frame.size.width - 20, height: height)
                return cellSize
            }else{
                return CGSize(width: collectionView.frame.size.width - 20, height: 76)
            }
            
        }else if(indexPath.item == 1){ //add comment layer
            let cellSize = CGSize(width: collectionView.frame.size.width - 20, height: addCommentCellHeight)
            return cellSize
            
        }else if(indexPath.item == 2){ //divider
            let cellSize = CGSize(width: collectionView.frame.size.width - 20, height: 0)
            return cellSize
            
        }else{ //regular item
            if let commentText = self.allTopicComments[indexPath.item - 3]["text"] as? String{
                let labelHeight = PublicStaticMethodsAndData.getHeight(for: commentText, with: UIFont(name: "Cordia New", size: 25)!, width: collectionView.frame.size.width - 20 - 84)
                let cellSize = CGSize(width: collectionView.frame.size.width - 20, height: labelHeight + 46)
                return cellSize
            }else{
                return CGSize(width: collectionView.frame.size.width - 20, height: 76)
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: Other Functions
    
    @objc private func detachListeners(){
        if let thisUserUniDomain = self.thisUserProfile["uni_domain"] as? String, let topicID = self.thisTopic["id"] as? String, let thisUserID = self.thisUserProfile["id"] as? String{
            self.baseDatabaseReference.collection("universities").document(thisUserUniDomain).collection("topics").document(topicID).updateData(["looking_ids" : FieldValue.arrayRemove([thisUserID])])
        }
        if(thisTopicRegistration != nil){
            thisTopicRegistration?.remove()
        }
        if(commentsRegistration != nil){
            commentsRegistration?.remove()
        }
    }
    
    private func addThisUserToLookingIds(){
        if let thisUserUniDomain = self.thisUserProfile["uni_domain"] as? String, let topicID = self.thisTopic["id"] as? String, let thisUserID = self.thisUserProfile["id"] as? String{
            self.baseDatabaseReference.collection("universities").document(thisUserUniDomain).collection("topics").document(topicID).updateData(["looking_ids" : FieldValue.arrayUnion([thisUserID])], completion: { (err) in
            if let err = err{
                    print("Error adding user to looking ids in board topic: \(err)")
                }else{
                
                
                    ///updating the current topic to include me in the looking id's
                
                    // get existing items, or create new array if doesn't exist
                    var existingItems = self.thisTopic["looking_ids"] as? [String] ?? [String]()

                    // append the item
                    existingItems.append(thisUserID)

                    // replace back into `looking_ids`
                    self.thisTopic["looking_ids"] = existingItems

                    self.prepareTopic()


                }
            })
        }
    }
    
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
        self.baseDatabaseReference.collection("reports").whereField("reportee", isEqualTo: self.thisUserProfile["id"] as! String).whereField("target", isEqualTo: self.thisTopic["id"] as? String).getDocuments() { (querySnapshot, err) in
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //called every single time a segway is called
        if(segue.identifier == "topicToProfile"){
            let vc = segue.destination as! ViewFullProfileActivity
            vc.thisUserProfile = self.thisUserProfile
            vc.otherUserID = self.imageAuthorID
        }
    }
}

extension String {
    func replace(_ with: String, at index: Int) -> String {
        var modifiedString = String()
        for (i, char) in self.enumerated() {
            modifiedString += String((i == index) ? with : String(char))
        }
        return modifiedString
    }
}
