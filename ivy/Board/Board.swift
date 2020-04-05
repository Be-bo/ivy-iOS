//
//  Board.swift
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

class Board: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, BoardLayoutDelegate{



    //MARK: Variables and Constant

    public var thisUserProfile = Dictionary<String, Any>()
    private let baseDatabaseReference = Firestore.firestore()
    private let baseStorageReference = Storage.storage()
    private let topicCollectionIdentifier = "TopicCollectionViewCell"
    private let questionOfTheDayIdentifier = "QuestionOfDayCollectionViewCell"
    private let createTopicButtonIdentifier = "CreateTopicCell"

    @IBOutlet weak var boardCollectionView: UICollectionView!

    private var allTopicIdNamePairs = Dictionary<String, Any>()
    private var allTopics: [Dictionary<String, Any>] = []         //arraylist holding dics of all topics
    private var topicClicked = Dictionary<String,Any>()                       //to know which topic cell been clicked
    private var registration:ListenerRegistration? = nil
    private var ofthedayRegistration:ListenerRegistration? = nil





    // MARK: Base Functions

    override func viewDidLoad() {
        super.viewDidLoad()
        if (PublicStaticMethodsAndData.checkProfileIntegrity(profileToCheck: thisUserProfile)){ //make sure user profile exists
            setUpNavigationBar()
            setupCollectionViews()
        }
    }

    private func setupCollectionViews(){
        boardCollectionView?.contentInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        if let layout = boardCollectionView?.collectionViewLayout as? BoardCollectionViewLayout {
            layout.delegate = self
        }
        boardCollectionView.register(UINib(nibName:questionOfTheDayIdentifier, bundle: nil), forCellWithReuseIdentifier: questionOfTheDayIdentifier)
        boardCollectionView.register(UINib(nibName:topicCollectionIdentifier, bundle: nil), forCellWithReuseIdentifier: topicCollectionIdentifier)
        boardCollectionView.register(UINib(nibName: createTopicButtonIdentifier, bundle: nil), forCellWithReuseIdentifier: createTopicButtonIdentifier)
        boardCollectionView.delegate = self
        boardCollectionView.dataSource = self
    }

    @objc private func setUp(){ //initial setup method when the ViewController's first created
        startListeningToTopics()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        detachListeners()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(setUp), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(detachListeners), name: UIApplication.didEnterBackgroundNotification, object: nil)
        setUp()
    }

    private func setUpNavigationBar(){
        let titleImgView = UIImageView(image: UIImage.init(named: "ivy_logo_small"))
        titleImgView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        titleImgView.contentMode = .scaleAspectFit
        navigationItem.titleView = titleImgView

        //U of C Logo Left Top Corneur
        let uOfCImgView = UIButton(type: .custom)
        uOfCImgView.frame = CGRect(x: 0.0, y: 0.0, width: 35, height: 35)
        uOfCImgView.setImage(UIImage(named:"top_bar_uOfC_Logo"), for: .normal)
        uOfCImgView.adjustsImageWhenHighlighted = false //keep color when button is diabled
        uOfCImgView.isEnabled = false //make u of c button unclickable
        let uOfCButtonItem = UIBarButtonItem(customView: uOfCImgView)
        let curruOfCWidth = uOfCButtonItem.customView?.widthAnchor.constraint(equalToConstant: 35)
        curruOfCWidth?.isActive = true
        let curruOfCHeight = uOfCButtonItem.customView?.heightAnchor.constraint(equalToConstant: 35)
        curruOfCHeight?.isActive = true

        //Settings Button Right Top Corneur
        let settingsButton = UIButton(type: .custom)
        settingsButton.frame = CGRect(x: 0.0, y: 0.0, width: 35, height: 35)
        settingsButton.setImage(UIImage(named:"settings"), for: .normal)
        settingsButton.addTarget(self, action: #selector(self.settingsClicked), for: .touchUpInside)
        let settingsButtonItem = UIBarButtonItem(customView: settingsButton)
        let currWidth = settingsButtonItem.customView?.widthAnchor.constraint(equalToConstant: 35)
        currWidth?.isActive = true
        let currHeight = settingsButtonItem.customView?.heightAnchor.constraint(equalToConstant: 35)
        currHeight?.isActive = true

        //Share Button Next To Settings
        let shareButton = UIButton(type: .custom)
        shareButton.frame = CGRect(x: 0.0, y: 0.0, width: 35, height: 35)
        shareButton.setImage(UIImage(named:"share"), for: .normal)
        shareButton.addTarget(self, action: #selector(self.shareTapped), for: .touchUpInside)
        let shareButtonItem = UIBarButtonItem(customView: shareButton)
        let currShareWidth = shareButtonItem.customView?.widthAnchor.constraint(equalToConstant: 35)
        currShareWidth?.isActive = true
        let currShareHeight = shareButtonItem.customView?.heightAnchor.constraint(equalToConstant: 35)
        currShareHeight?.isActive = true

        self.navigationItem.leftBarButtonItem = uOfCButtonItem
        self.navigationItem.rightBarButtonItems = [settingsButtonItem, shareButtonItem]
    }








    // MARK: IBActions and Topic Posting

    @objc func settingsClicked() {
        self.performSegue(withIdentifier: "BoardToSettings" , sender: self) //pass data over to
    }

    @objc func shareTapped(){
        let activityController = UIActivityViewController(activityItems: ["Hi, thought you'd like ivy! Check it out here: https://apps.apple.com/ca/app/ivy/id1479966843."], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }

    @objc func createTopic() {
        if (self.checkIfTwoHoursSinceLastPosting()){
            let ac = UIAlertController(title: "Post a Topic on the Board! (Use emojis for more engagement.)", message: nil, preferredStyle: .alert)
            ac.view.tintColor = UIColor.ivyGreen
            ac.addTextField()
            ac.textFields![0].placeholder = "Topic Name"

            let submitAction = UIAlertAction(title: "Post", style: .default) { [unowned ac] _ in
                let topicInput = ac.textFields![0]
                if let topicInput = topicInput.text {
                    if(topicInput.count>1 && !(topicInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)){
//                        if(!self.checkForProfanity(topicInput: topicInput.lowercased())){  //if no profanity exists
                        self.pushTopic(isAnonymous: false, inputText: topicInput, ac:ac)
                        PublicStaticMethodsAndData.barInteraction(for: self.view)
//                        }
                    }else{
                        PublicStaticMethodsAndData.createInfoDialog(titleText: "Please enter a Topic name atleast 2 characters long.", infoText: "", context: self)
                    }
                }
            }

            let submitAnonyAction = UIAlertAction(title: "Post Anonymously", style: .default) { [unowned ac] _ in
                let topicInput = ac.textFields![0]
                if let topicInput = topicInput.text {
                    if(topicInput.count>1 && !(topicInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)){
//                        if(!self.checkForProfanity(topicInput: topicInput.lowercased())){
                        self.pushTopic(isAnonymous: true, inputText: topicInput, ac:ac)
                        PublicStaticMethodsAndData.barInteraction(for: self.view)
//                        }
                    }else{
                        PublicStaticMethodsAndData.createInfoDialog(titleText: "Please enter a Topic name atleast 2 characters long.", infoText: "", context: self)
                    }
                }
            }

            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { [unowned ac] _ in
            }
            ac.addAction(submitAction)
            ac.addAction(submitAnonyAction)
            ac.addAction(cancelAction)
            self.present(ac, animated: true)
        }else{
            PublicStaticMethodsAndData.createInfoDialog(titleText: "Invalid Action", infoText: "You posted a topic recently. Come back later!", context: self)
        }
    }
    
    //TODO: newly posted topic not showing when pushed (app has to be restarted) - Left off -> look at the discrepancy between added case and cellforitemat calls

    func pushTopic(isAnonymous:Bool, inputText:String, ac:UIAlertController) {
        var newTopic = Dictionary<String, Any>()
        newTopic["author_id"] = self.thisUserProfile["id"] as? String
        newTopic["id"] = NSUUID().uuidString
        newTopic["is_active"] = true
        newTopic["is_anonymous"] = isAnonymous
        newTopic["creation_millis"] = Date().millisecondsSince1970
        newTopic["uni_domain"] = self.thisUserProfile["uni_domain"] as? String
        newTopic["text"] = inputText
        newTopic["looking_ids"] = []
        newTopic["commenting_ids"] = []

        if let uniDomain = self.thisUserProfile["uni_domain"] as? String, let userID = self.thisUserProfile["id"] as? String, let newTopicID = newTopic["id"] as? String {
            self.baseDatabaseReference.collection("universities").document(uniDomain).collection("userprofiles").document(userID).updateData(["last_topic_millis" : Date().millisecondsSince1970]) { (err) in
                if let err = err {
                    print("Error updating universities document in Board with a new topic: \(err)")
                    PublicStaticMethodsAndData.createInfoDialog(titleText: "Oops!", infoText: "Something went wrong, try again in a moment. :-(", context: self)
                } else {
                    self.baseDatabaseReference.collection("universities").document(uniDomain).collection("topics").document(newTopicID).setData(newTopic) { (err1) in
                        if let err1 = err1{
                            print("Error pushing topic to the Board: \(err1)")
                            PublicStaticMethodsAndData.createInfoDialog(titleText: "Oops!", infoText: "Something went wrong, try again in a moment. :-(", context: self)
                        }else{
                            ac.dismiss(animated: true, completion: nil)
                            self.topicClicked = newTopic
//                            self.detachListeners()
                            self.performSegue(withIdentifier: "boardToTopicSegue" , sender: self) //pass data over to
                        }
                    }
                }
                PublicStaticMethodsAndData.allowInteraction(for: self.view)
            }
        }
    }

    func checkIfTwoHoursSinceLastPosting() -> Bool{
        if let userLastTopicMillis = self.thisUserProfile["last_topic_millis"] as? Int64{
            if(userLastTopicMillis != 0){
                print("Date().millisecondsSince1970", Date().millisecondsSince1970)
                print("user last topic millis: ", userLastTopicMillis)
                if((Date().millisecondsSince1970 - userLastTopicMillis) < PublicStaticMethodsAndData.LAST_TOPIC_CREATION_TIME_DIFFERENCE){
                    return false
                }
            }
        }
        return true
    }











    // MARK: Profanity Checking

    func checkForProfanity(topicInput: String) -> Bool{ //if the topic input has no profanity then return true
        var hasProfanity:Bool = false

        for(index,_) in PublicStaticMethodsAndData.profanity_list.enumerated(){
            if (topicInput.contains(PublicStaticMethodsAndData.profanity_list[index])){
                var exceptionPresent:Bool  = false
                for(_, profanityj) in PublicStaticMethodsAndData.profanity_exceptions_list.enumerated(){
                    if (topicInput.contains(profanityj) && topicInput.contains(PublicStaticMethodsAndData.profanity_list[index])) {
                        exceptionPresent = true
                        break
                    }
                }
                if(exceptionPresent){ continue }

                if let rangeForStart: Range<String.Index> = topicInput.range(of: PublicStaticMethodsAndData.profanity_list[index]),let startingIndex: Int = topicInput.distance(from: topicInput.startIndex, to: rangeForStart.lowerBound){
                    let endingIndex = startingIndex + PublicStaticMethodsAndData.profanity_list[index].count
                    if(startingIndex == 0 && topicInput.contains(PublicStaticMethodsAndData.profanity_list[index] + " ")){
                        PublicStaticMethodsAndData.createInfoDialog(titleText: "Profanity Problem", infoText: "The title contains a profanity", context: self)
                        hasProfanity = true
                        break
                    }
                    if (endingIndex == topicInput.count && topicInput.contains(" " + PublicStaticMethodsAndData.profanity_list[index])){
                        PublicStaticMethodsAndData.createInfoDialog(titleText: "Profanity Problem", infoText: "The title contains a profanity", context: self)
                        hasProfanity = true
                        break
                    }

                    if(topicInput.contains(" " + PublicStaticMethodsAndData.profanity_list[index] + " ")){
                        PublicStaticMethodsAndData.createInfoDialog(titleText: "Profanity Problem", infoText: "The title contains a profanity", context: self)
                        hasProfanity = true
                        break
                    }
                    if(topicInput.count == PublicStaticMethodsAndData.profanity_list[index].count){
                        PublicStaticMethodsAndData.createInfoDialog(titleText: "Profanity Problem", infoText: "The title contains a profanity", context: self)
                        hasProfanity = true
                        break
                    }
                }
            }
        }
        return hasProfanity
    }













    // MARK: Database Methods

    func startListeningToTopics(){
        self.allTopics = [] //clear the topics to make sure its empty and will repull everything 
        if let uniDomain =  self.thisUserProfile["uni_domain"] as? String{
            registration = self.baseDatabaseReference.collection("universities").document(uniDomain).collection("topics").addSnapshotListener({ (querySnapshot, err) in
                
                guard let snapshot = querySnapshot else {
                    print("Error initializing in Board: \(err!)")
                    return
                }

                if(self.allTopics.count == 0){
                    self.allTopics.append(Dictionary<String, Any>()) //an empty topic for the first item representing the create topic button
                }
                snapshot.documentChanges.forEach { diff in
                    if (diff.type == .added) {
                        let newTopic =  diff.document.data()
                        let dontAdd = self.allTopics.contains { (topic) -> Bool in
                            if let newTopicId = newTopic["id"] as? String, let currentlyCheckingId = topic["id"] as? String, newTopicId == currentlyCheckingId {
                               return true
                            }else{
                                return false
                            }
                        }
                        if(self.allTopics.count < 1 || !dontAdd){
                            self.allTopics.append(newTopic)
                            self.boardCollectionView.reloadData()
                        }
                    }

                    if (diff.type == .modified) {
                        let modifiedTopic = diff.document.data()
                        if let modifiedTopicID = modifiedTopic["id"] as? String{
                            let optionalIndex = self.allTopics.firstIndex { (topic) -> Bool in
                                if let currentlyCheckingId = topic["id"] as? String, modifiedTopicID == currentlyCheckingId{
                                    return true
                                }else{
                                    return false
                                }
                            }
                            if let posIndex = optionalIndex {
                                self.allTopics[posIndex] = modifiedTopic
                                self.boardCollectionView.reloadData()
                            }
                        }
                    }
                    if (diff.type == .removed) {
                        let removedTopic = diff.document.data()
                        let optionalIndex = self.allTopics.firstIndex { (topic) -> Bool in
                            if let removedTopicId = removedTopic["id"] as? String, let currentlyCheckingId = topic["id"] as? String, removedTopicId == currentlyCheckingId{
                                return true
                            }else{
                                return false
                            }
                        }
                        if let posIndex = optionalIndex {
                            self.allTopics.remove(at: posIndex)
                            self.boardCollectionView.reloadData()
                            //TODO: when removing invalidate layout since it'll need to recalc the layout
                        }
                    }
                }
                self.moveQOTDtoFront()
            })
        }
    }

    func moveQOTDtoFront(){
        for i in 1..<allTopics.count{
            if let topicId = allTopics[i]["id"] as? String, topicId == "oftheday"{
                let topicToMove = allTopics[1]
                allTopics[1] = allTopics[i]
                allTopics[i] = topicToMove
                break
            }
        }
        self.boardCollectionView.reloadData()
    }

    func updateProfile(updatedProfile: Dictionary<String, Any>){ //called externally from main under mainTabController
        self.thisUserProfile = updatedProfile
    }
    
    @objc private func detachListeners(){
           if(registration != nil){
               registration?.remove()
           }
       }













    //MARK: Collection View Methods

    func collectionView(collectionView: UICollectionView, heightForLabelAt indexPath: IndexPath, with width: CGFloat) -> CGFloat {
        if(indexPath.item == 0){ //create topic button
            return CGFloat(38)
        }
        if let topic = allTopics[indexPath.item] as? Dictionary<String, Any>, let topicText = topic["text"] as? String{
            let labelHeight = PublicStaticMethodsAndData.getHeight(for: topicText, with: UIFont(name: "Cordia New", size: 25)!, width: width)
            if(indexPath.item == 1){
                return labelHeight + CGFloat(100) //8 for margins, then 30 for image/authoredCommented/numLooking layer + trial and error + QOTD space
            }else{
                return labelHeight + CGFloat(75) //8 for margins, then 30 for image/authoredCommented/numLooking layer + trial and error
            }
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allTopics.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(indexPath.item == 0){ //if create topic button
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: createTopicButtonIdentifier, for: indexPath) as! CreateTopicCell
            let tap = UITapGestureRecognizer(target: self, action: #selector(createTopic))
            cell.createButton.addGestureRecognizer(tap)
            return cell
        }else if(indexPath.item == 1){ //if QOTD
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: questionOfTheDayIdentifier, for: indexPath) as! QuestionOfDayCollectionViewCell
            populateQOTDCell(cell:cell, topic: self.allTopics[indexPath.item])
            cell.styleCell(cell: cell)
            return cell
        }else{ //if standard topic
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: topicCollectionIdentifier, for: indexPath) as! TopicCollectionViewCell
            populateTopicCell(cell: cell, topic: self.allTopics[indexPath.item])
            cell.styleCell(cell: cell)
            return cell
        }
    }

    func populateTopicCell(cell:TopicCollectionViewCell, topic:Dictionary<String,Any>){
        if let topicName = topic["text"] as? String, let lookingIDs = topic["looking_ids"] as? [String],
            let commentingIDs = topic["commenting_ids"] as? [String], let topicAuthID = topic["author_id"] as? String,
            let thisUserID = self.thisUserProfile["id"] as? String {
            cell.textView.text = topicName

            if(!lookingIDs.isEmpty){cell.numberViewingLabel.text = String(lookingIDs.count)}else{cell.numberViewingLabel.text = "0"}
            if (topicAuthID == thisUserID){ //this user created the topic so change the text to authored
                cell.authOrCommentLabel.text = "Authored"
            }else if(!commentingIDs.isEmpty && commentingIDs.contains(thisUserID)){ //commented
                cell.authOrCommentLabel.text = "Commented"
            }else{  //neither so empty be default
                cell.authOrCommentLabel.text = ""
            }
        }
    }

    func populateQOTDCell(cell:QuestionOfDayCollectionViewCell,topic:Dictionary<String,Any>){
        if let topicName = topic["text"] as? String, let lookingIDs = topic["looking_ids"] as? [String],
            let commentingIDs = topic["commenting_ids"] as? [String], let thisUserID = self.thisUserProfile["id"] as? String {
            cell.textView.text = topicName
            if(!lookingIDs.isEmpty){cell.numberViewingLabel.text = String(lookingIDs.count)}else{cell.numberViewingLabel.text = "0"}
            if(!commentingIDs.isEmpty && commentingIDs.contains(thisUserID)){ //commented
                cell.commentLabel.isHidden = false
            }else{  //neither so empty be default
                cell.commentLabel.isHidden = true
            }

        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) { //on click of the event, pass the data from the event through a segue to the event.swift page
        if (indexPath == IndexPath(item: 0, section: 0)) {
            //do nothing
        }
        else if (self.allTopics.count > 1 && indexPath.item > 0) {              //0th item create topic button
            let currentTopic = self.allTopics[indexPath.item]
            self.topicClicked = currentTopic
//            self.detachListeners()
            self.performSegue(withIdentifier: "boardToTopicSegue" , sender: self) //pass data over
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //called every single time a segue is called
        if segue.identifier == "boardToTopicSegue" {
            let vc = segue.destination as! BoardTopic
            vc.thisTopic = self.topicClicked
            vc.thisUserProfile = self.thisUserProfile
        }
        //        self.tabBarController?.tabBar.isHidden = true
    }
}









// MARK: Column Flow Layout https://stackoverflow.com/questions/14674986/uicollectionview-set-number-of-columns
// used in BoardTopic.swift for now, will be moved to a separate file

class ColumnFlowLayout: UICollectionViewFlowLayout {

    let cellsPerRow: Int

    init(cellsPerRow: Int, minimumInteritemSpacing: CGFloat = 0, minimumLineSpacing: CGFloat = 0, sectionInset: UIEdgeInsets = .zero) {
        self.cellsPerRow = cellsPerRow
        super.init()

        self.minimumInteritemSpacing = minimumInteritemSpacing
        self.minimumLineSpacing = minimumLineSpacing
        self.sectionInset = sectionInset
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepare() {
        super.prepare()

        guard let collectionView = collectionView else { return }
        let marginsAndInsets = sectionInset.left + sectionInset.right + collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right + minimumInteritemSpacing * CGFloat(cellsPerRow - 1)
        let itemWidth = ((collectionView.bounds.size.width - marginsAndInsets) / CGFloat(cellsPerRow)).rounded(.down)
        itemSize = CGSize(width: itemWidth, height: itemWidth)
    }

    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds) as! UICollectionViewFlowLayoutInvalidationContext
        context.invalidateFlowLayoutDelegateMetrics = newBounds.size != collectionView?.bounds.size
        return context
    }

}
