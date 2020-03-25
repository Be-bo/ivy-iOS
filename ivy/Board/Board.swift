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

class Board: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
   
    
    //MARK: Variables and Constant
    public var thisUserProfile = Dictionary<String, Any>()
    private let baseDatabaseReference = Firestore.firestore()
    private let baseStorageReference = Storage.storage()
    
    private let topicCollectionIdentifier = "TopicCollectionViewCell"
    @IBOutlet weak var topicCollectionView: UICollectionView!

    
    private var allTopicIdNamePairs = Dictionary<String, Any>()
    private var allTopics: [Dictionary<String, Any>] = []         //arraylist holding dics of all topics
    private var topicClicked = Dictionary<String,Any>()                       //to know which topic cell been clicked
    private var registration:ListenerRegistration? = nil
    
    private var dataLoaded = false

    
    
    
    // MARK: Base Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        if (PublicStaticMethodsAndData.checkProfileIntegrity(profileToCheck: thisUserProfile)){ //make sure user profile exists
            setUpNavigationBar()
            setUp()
        }
    }
    
    
    private func setUp(){ //initial setup method when the ViewController's first created
        
        
//        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: UIApplication.willEnterForegroundNotification, object: nil) //add a listener to the app to call refresh inside of this VC when the app goes from background to foreground (is maximized)
    
//        self.hideKeyboardOnTapOutside()
      
        
        topicCollectionView.delegate = self
        topicCollectionView.dataSource = self
        topicCollectionView.register(UINib(nibName:topicCollectionIdentifier, bundle: nil), forCellWithReuseIdentifier: topicCollectionIdentifier)
        startListeningToTopics()
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
    
    // MARK: Actions
    @objc func settingsClicked() {
        self.performSegue(withIdentifier: "BoardToSettings" , sender: self) //pass data over to
    }
    
    @objc func shareTapped(){ //TODO: potentially move this to the PublicStaticMethodsAndData
        let activityController = UIActivityViewController(activityItems: ["Hi, thought you'd like ivy! Check it out here: https://apps.apple.com/ca/app/ivy/id1479966843."], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)

    }
    
    @IBAction func onClickCreateTopic(_ sender: Any) {
        
        
        if (self.checkIfTwoHoursSinceLastPosting()){
            let ac = UIAlertController(title: "Post a Topic on the Board!", message: nil, preferredStyle: .alert)
            ac.addTextField()
            ac.textFields![0].placeholder = "Topic Name"
            
            let submitAction = UIAlertAction(title: "Post", style: .default) { [unowned ac] _ in
                let topicInput = ac.textFields![0]
                    if let topicInput = topicInput.text {
                       if(topicInput.count>1){
                        if(!self.checkForProfanity(topicInput: topicInput.lowercased())){  //if no profanity exists
                            self.pushTopic(isAnonymous: false, inputText: topicInput, ac:ac)
                            //TODO: show progress bar and dismiss the rest
                        }
                       }else{
                           PublicStaticMethodsAndData.createInfoDialog(titleText: "Please enter a Topic name atleast 2 characters long.", infoText: "", context: self)
                       }
                    }
            }
            
            let submitAnonyAction = UIAlertAction(title: "Post Anonymously", style: .default) { [unowned ac] _ in
                let topicInput = ac.textFields![0]
                if let topicInput = topicInput.text {
                   if(topicInput.count>1){
                    if(!self.checkForProfanity(topicInput: topicInput.lowercased())){
                        self.pushTopic(isAnonymous: true, inputText: topicInput, ac:ac)
                        //TODO: show progress bar and dismiss the rest
                    }
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
            PublicStaticMethodsAndData.createInfoDialog(titleText: "Invalid Action", infoText: "You posted it recently. Come back later!", context: self)
        }
    }
    
    
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
            self.baseDatabaseReference.collection("universities").document(uniDomain).collection("userprofiles").document(userID).updateData(["last_topic_millis" : Date().timeIntervalSince1970]) { (err) in
                if let err = err {
                    print("Error updating universities document in Board with a new topic: \(err)")
                    PublicStaticMethodsAndData.createInfoDialog(titleText: "Oops!", infoText: "Something went wrong, try again in a moment. :-(", context: self)
                } else {
                    self.baseDatabaseReference.collection("universities").document(uniDomain).collection("topics").document(newTopicID).setData(newTopic) { (err1) in
                        if let err1 = err1{
                            //TODO: dismiss progress bar
                            print("Error pushing topic in board: \(err1)")
                            PublicStaticMethodsAndData.createInfoDialog(titleText: "Oops!", infoText: "Something went wrong, try again in a moment. :-(", context: self)
                        }else{
                            ac.dismiss(animated: true, completion: nil)
                            self.topicClicked = newTopic
                            self.performSegue(withIdentifier: "boardToTopicSegue" , sender: self) //pass data over to
                        }
                    }
                }
            }
        }
    }
    
    //if the topic input has no profanity then return true
    func checkForProfanity(topicInput: String) -> Bool{
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
    
    func checkIfTwoHoursSinceLastPosting() -> Bool{
        if let userLastTopicMillis = self.thisUserProfile["last_topic_millis"] as? Int64{
            var millisOfLastTopic = userLastTopicMillis
            if(millisOfLastTopic != 0){
                if((Date().millisecondsSince1970 - millisOfLastTopic) < PublicStaticMethodsAndData.LAST_TOPIC_CREATION_TIME_DIFFERENCE){
                    return false
                }
            }
        }
        return true
    }
    
    // MARK: Data Acquisition Methods
    func startListeningToTopics(){
        if let uniDomain =  self.thisUserProfile["uni_domain"] as? String{
            registration = self.baseDatabaseReference.collection("universities").document(uniDomain).collection("topics").addSnapshotListener({ (querySnapshot, err) in
                
                guard let snapshot = querySnapshot else {
                    print("Error initializing in Board: \(err!)")
                    return
                }
                
                snapshot.documentChanges.forEach { diff in
                    if (diff.type == .added) {
                        let newTopic =  diff.document.data()
                        if let newTopicID = newTopic["id"] as? String{ //if is question of day, return, dont add
                            if(newTopicID == "oftheday") {return}
                        }
                        //TODO: check if exists before appending? Like in Android?
                        self.allTopics.append(newTopic)
                        let indexPath = IndexPath(item: self.allTopics.count - 1, section: 0)
                        self.topicCollectionView.insertItems(at: [indexPath])
                    }
                    
                    if (diff.type == .modified) {
                        let modifiedTopic = diff.document.data()
                        if let modifiedTopicID = modifiedTopic["id"] as? String{ //if is question of day, return, dont add
                            if(modifiedTopicID == "oftheday") {return}
                        }
                        
                        if let modifiedTopicID = modifiedTopic["id"] as? String{
                            let posModifiedIndex = self.locateIndexOfTopic(id: modifiedTopicID)
                            self.allTopics[posModifiedIndex] = modifiedTopic
                            let indexPath = IndexPath(item: posModifiedIndex, section: 0)
                            self.topicCollectionView.reloadItems(at: [indexPath])
                            return
                        }
                    }
                    if (diff.type == .removed) {
                        let removedTopic = diff.document.data()
                        if let removedTopicID = removedTopic["id"] as? String{
                            let posRemoved = self.locateIndexOfTopic(id: removedTopicID)
                            self.allTopics.remove(at: posRemoved)
                            self.topicCollectionView.reloadData()
                            return
                        }
                    }
                }
            })
        }
    }
    
    //so we know what index to removed from all topics when deleting
    func locateIndexOfTopic(id:String) -> Int {
        var position = 0
        for (index, chat) in self.allTopics.enumerated(){
            if id == chat["id"] as! String{
                position = index
            }
        }
        return position
    }
    
    

    
    //called externally from main under mainTabController
    func updateProfile(updatedProfile: Dictionary<String, Any>){
        self.thisUserProfile = updatedProfile
    }
    
    
    
    //MARK: Collection View Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allTopics.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let topicCell = collectionView.dequeueReusableCell(withReuseIdentifier: topicCollectionIdentifier, for: indexPath) as! TopicCollectionViewCell
        
        
        var currentTopic = self.allTopics[indexPath.item]
        if let topicName = currentTopic["text"] as? String {
            topicCell.textView.text = topicName
        }
        
        
        
        //TODO: populate the topic cell with the title of the topic
        return topicCell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSize = CGSize(width: 140, height: 140)
        return cellSize
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) { //on click of the event, pass the data from the event through a segue to the event.swift page
        if self.allTopics.count >= 0 {
            var currentTopic = self.allTopics[indexPath.item]
            self.topicClicked = currentTopic
            self.performSegue(withIdentifier: "boardToTopicSegue" , sender: self) //pass data over to

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



