//
//  Quad.swift
//  ivy
//
//  Created by Robert on 2019-07-28.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class Quad: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: Variables and Constants
    
    private var thisUserProfile = Dictionary<String, Any>()
    private var allQuadProfiles = [Dictionary<String, Any>]()
    private let cellId = "QuadCard"
    private let baseDatabaseReference = Firestore.firestore()
    private var requests = Dictionary<String, Any>()
    private var friends = Dictionary<String, Any>()
    private var block_list = Dictionary<String, Any>()
    private var blocked_by = Dictionary<String, Any>()
    
    
    
    
    // MARK: IBOutlets and IBActions
    
    @IBOutlet weak var quadCollectionView: UICollectionView!
    
    
    
    
    
    
    
    // MARK: Base and Override Functions
    
    override func viewDidLoad() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Actions", style: .plain, target: self, action: #selector(showActions))
        super.viewDidLoad()
        self.hideKeyboardOnTapOutside()
        setUpNavigationBar()
        setUp()
    }
    
    private func setUp(){ //set up everything we need for the UI
        quadCollectionView.delegate = self
        quadCollectionView.dataSource = self
        quadCollectionView.register(UINib(nibName: "Card", bundle: nil), forCellWithReuseIdentifier: cellId)
//        let sidePadding = (quadCollectionView.frame.size.width - cell width)/2 //side padding for each card is 5% of collection view's width
//        quadCollectionView.contentInset = UIEdgeInsets(top: 0, left: sidePadding, bottom: 0, right: sidePadding)
        
        if(!thisUserProfile.values.isEmpty){
            loadQuadProfiles()
        }
    }
    
    private func setUpNavigationBar(){
        let titleImgView = UIImageView(image: UIImage.init(named: "ivy_logo"))
        titleImgView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        titleImgView.contentMode = .scaleAspectFit
        navigationItem.titleView = titleImgView
    }
    
    
    
    @objc func showActions() {
        let actionSheet = UIAlertController(title: "Actions", message: .none, preferredStyle: .actionSheet)
        actionSheet.view.tintColor = UIColor.ivyGreen
        
        //ADDING ACTIONS TO THE ACTION SHEET
        actionSheet.addAction(UIAlertAction(title: "message", style: .default, handler: self.onClickSendHiMsg))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    
    
    //when user wants to send hi message to another user from quad from the back of the card.
    func onClickSendHiMsg(alert:UIAlertAction!){
        
        //TODO: figure out how to click on text label/button from back of card, and actually send message to user
        //extract message from text label
        var sendHiMessage = "Tester message for now"
        
    }
    
    
    // MARK: Data Acquisition Functions
    
    func updateProfile(updatedProfile: Dictionary<String, Any>){ //a method called from the outside by the MainTabController which listens to changes in this user's profile and pushes them right away
        thisUserProfile = updatedProfile
    }
    
    private func loadQuadProfiles(){
        if let uni = thisUserProfile["uni_domain"] as? String, let id = thisUserProfile["id"] as? String{
    
            baseDatabaseReference.collection("universities").document(uni).collection("userprofiles").document(id).collection("userlists").document("requests").getDocument() { (docSnapshot, err) in
                if let err = err{
                    print("Error getting requests: \(err)")
                }else{
                    if(docSnapshot?.exists ?? false){
                        self.requests = docSnapshot?.data() ?? Dictionary<String, Any>()
                    }
                }
                
                self.baseDatabaseReference.collection("universities").document(uni).collection("userprofiles").document(id).collection("userlists").document("friends").getDocument() { (docSnapshot1, err1) in
                    if let err1 = err1 {
                        print("Error getting friends: \(err1)")
                    }else{
                        if(docSnapshot1?.exists ?? false){
                            self.friends = docSnapshot1?.data() ?? Dictionary<String, Any>()
                        }
                    }
                    
                    self.baseDatabaseReference.collection("universities").document(uni).collection("userprofiles").document(id).collection("userlists").document("block_list").getDocument() { (docSnapshot2, err2) in
                        if let err2 = err2 {
                            print("Error getting block list: \(err2)")
                        }else{
                            if(docSnapshot2?.exists ?? false){
                                self.block_list = docSnapshot2?.data() ?? Dictionary<String, Any>()
                            }
                        }
                        
                        self.baseDatabaseReference.collection("universities").document(uni).collection("userprofiles").document(id).collection("userlists").document("blocked_by").getDocument() { (docSnapshot3, err3) in
                            if let err3 = err3 {
                                print("Error getting blocked by list: \(err3)")
                            }else{
                                if(docSnapshot3?.exists ?? false){
                                    self.blocked_by = docSnapshot3?.data() ?? Dictionary<String, Any>()
                                }
                            }
                            
                            self.baseDatabaseReference.collection("universities").document(uni).collection("userprofiles").getDocuments() { (querySnapshot, err4) in
                                if let err4 = err4 {
                                    print("Error getting Quad profiles: \(err4)")
                                } else {
                                    var newBatch = [Dictionary<String, Any>]()
                                    for document in querySnapshot!.documents {
                                        if(document.exists){
                                            newBatch.append(document.data())
                                        }
                                    }
                                    self.addBatch(newProfiles: newBatch)
                                    self.quadCollectionView.reloadData()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    private func addBatch(newProfiles: [Dictionary<String, Any>]){
        for profile in newProfiles {
            if let profileId = profile["id"] as? String, let thisUserId = thisUserProfile["id"] as? String{
                if(profileId != thisUserId && requests[profileId] == nil && friends[profileId] == nil && block_list[profileId] == nil && blocked_by[profileId] == nil){
                    if let profileHidden = profile["profile_hidden"] as? Bool {
                        if(!profileHidden){
                            self.allQuadProfiles.append(profile)
                        }
                    }else{
                        self.allQuadProfiles.append(profile)
                    }
                }
            }
        }
    }
    
    //TODO: add the actual position for dealing with the infinite scrolling feature
    func setRequest(quadCard:Card, pos: Int){

      
        //moving text field to the front to make it clickable
        quadCard.shadowOuterContainer.bringSubviewToFront(quadCard.cardContainer)
        quadCard.shadowOuterContainer.bringSubviewToFront(quadCard.cardContainer.back)
        
        //set on click listener for send message button
        quadCard.back.sayHiButton.addTarget(self, action: #selector(sayHiButtonClicked), for: .touchUpInside)
    
        //attach the card,pos, and orig pos to button to be able to use when clicked
        quadCard.back.sayHiButton.Card = quadCard
        quadCard.back.sayHiButton.pos = pos
        

        

    }
    
    //on click of the send hi message on back of card
    @objc func sayHiButtonClicked(_ sender: subclassedUIButton) {
        
        let card = sender.Card
        let pos = sender.pos
        
        //check length of input field, default is 0 if they didnt input anything
        if (sender.Card?.back.sayHiMessageTextField.text?.count ?? 0 > 1){
            self.sendRequest(quadCard: card!, pos: pos!)
        }else{
            //TODO: display the error message when message si to short to front end
            print("Your message is to short!")
        }
        
    }
    
    //TODO: deal with actual position once infinite collection view is added
    func sendRequest(quadCard:Card, pos: Int){
        var conversationReference: DocumentReference
        var current = allQuadProfiles[pos]
        conversationReference = self.baseDatabaseReference.collection("conversations").document()
        var participants = [String]()
        var participantNames = [String]()
        participants.append(self.thisUserProfile["id"] as! String)
        participants.append(current["id"] as! String)
        participantNames.append(self.thisUserProfile["first_name"] as! String)
        participantNames.append(current["first_name"] as! String)
        var msgCounts = [CLong]()
        msgCounts.append(0)
        msgCounts.append(0)
        let mutedBy = [String]()
        
        
        //adding to request lists of user, where true is who sent, false is who recieved
        var temp = Dictionary<String, Any>()
        temp[current["id"] as! String] = true
        self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("userprofiles").document(self.thisUserProfile["id"] as! String).collection("userlists").document("requests").setData(temp, merge: true)
        
        temp = Dictionary<String, Any>()//reset
        temp[self.thisUserProfile["id"] as! String] = false
        self.baseDatabaseReference.collection("universities").document(current["uni_domain"] as! String).collection("userprofiles").document(current["id"] as! String).collection("userlists").document("requests").setData(temp, merge: true)
        
        
        //create new conversation object
        var newConversation = Dictionary<String, Any>()
        newConversation["id"] = conversationReference.documentID
        newConversation["name"] = String(self.thisUserProfile["first_name"] as! String)+", "+String(current["first_name"] as! String)
        newConversation["participants"] = participants
        newConversation["is_request"] = true
        newConversation["last_message"] = quadCard.back.sayHiMessageTextField.text
        newConversation["last_message_author"] = self.thisUserProfile["id"] as! String
        newConversation["creation_time"] =  Date().millisecondsSince1970   //millis
        newConversation["participant_names"] =  participantNames
        newConversation["last_message_counts"] = msgCounts
        newConversation["last_message_millis"] = Date().millisecondsSince1970   //millis
        newConversation["message_count"] = 1
        newConversation["is_base_conversation"] = true
        newConversation["muted_by"] = mutedBy
        //push pbject to db
        self.baseDatabaseReference.collection("conversations").document(conversationReference.documentID).setData(newConversation)
        
        
        //create new message object
        var requestMessage = Dictionary<String, Any>()
        requestMessage["message_text"] = quadCard.back.sayHiMessageTextField.text
        requestMessage["author_id"] = self.thisUserProfile["id"] as! String
        requestMessage["author_first_name"] = self.thisUserProfile["first_name"] as! String
        requestMessage["author_last_name"] = self.thisUserProfile["last_name"] as! String
        requestMessage["conversation_id"] = conversationReference.documentID
        requestMessage["is_text_only"] = true
        requestMessage["file_reference"] = ""
        requestMessage["id"] = NSUUID().uuidString
        requestMessage["creation_time"] = Date().millisecondsSince1970   //millis
        //push message object to db
        self.baseDatabaseReference.collection("conversations").document(conversationReference.documentID).collection("messages").document(requestMessage["id"] as! String).setData(requestMessage)
        
        
        //remove profile from quad
        self.quadCollectionView.reloadData()
        
        //TODO:remove the card from the collection view once a user has sent a request over to that other user
    }
    
    
    
    
    
    // MARK: Collection View Delegate and Datasource Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allQuadProfiles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let quadCard = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! Card
        quadCard.setUp(user: allQuadProfiles[indexPath.item])
        
        
        
        //TODO: implement logic for dealing with actual pos
//        let actualPos = indexPath.item % allQuadProfiles.count
//        let current = allQuadProfiles[actualPos]
        let pos = indexPath.item
        self.setRequest(quadCard: quadCard, pos: pos);

        
        return quadCard
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize { //item size has to adjust based on current collection view dimensions (90% of the its size, the rest is padding - see the setUp() function)
        let cellSize = CGSize(width: self.quadCollectionView.frame.size.width * 0.97, height: self.quadCollectionView.frame.size.height * 0.97)
        return cellSize
    }
    
    
    
    
    
    // MARK: Collection View Behavior Functions
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let collectionViewCenterX = self.quadCollectionView.center.x //get the center of the collection view
        
        for cell in self.quadCollectionView.visibleCells {
            let basePosition = cell.convert(CGPoint.zero, to: self.view)
            let cellCenterX = basePosition.x + self.quadCollectionView.frame.size.width / 2.0 //get the center of the current cell
            let distance = abs(cellCenterX - collectionViewCenterX) //distance between them
            
            let tolerance : CGFloat = 0.02
            let multiplier : CGFloat = 0.105
            var scale = 1.00 + tolerance - ((distance/collectionViewCenterX)*multiplier) //scale the car based on how far it is from the center (tolerance and the multiplier are both arbitrary)
            if(scale > 1.0){ //don't go beyond 100% size
                scale = 1.0
            }
            cell.transform = CGAffineTransform(scaleX: scale, y: scale) //apply the size change
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) { //find the largest visibile cell once the scrolling animation finishes and scroll that one to the center
        var indexOfLargestCell = 0
        var largestWidth: CGFloat = 1
        
        for cell in self.quadCollectionView.visibleCells{
            if cell.frame.size.width >= largestWidth {
                largestWidth = cell.frame.size.width
                if let indexPath = self.quadCollectionView.indexPath(for: cell){
                    indexOfLargestCell = indexPath.item
                }
            }
        }
        
        self.quadCollectionView.scrollToItem(at: IndexPath(item: indexOfLargestCell, section: 0), at: .centeredHorizontally, animated: true)
    }
}

//extend UIButton to be able to add the card as a parameter to the button for adding on click target
class subclassedUIButton: UIButton {
    var Card: Card?
    var pos: Int?
    var origPos: Int?
}
