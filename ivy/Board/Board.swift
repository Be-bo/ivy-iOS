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
    private var allTopics = [Topic]()                                           //arraylist of all the topics
    private var IDtopicClicked:String = ""                       //to know which topic cell been clicked

    
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
        startLoadingData() //start loading the topic data
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
        
       
        let ac = UIAlertController(title: "Post a Topic on the Board!", message: nil, preferredStyle: .alert)

        ac.addTextField()
        ac.textFields![0].placeholder = "Topic Name"
     

        
        let submitAction = UIAlertAction(title: "Post", style: .default) { [unowned ac] _ in
        let topicInput = ac.textFields![0]
            if let topicInput = topicInput.text {
                if(topicInput.count>1){
                }else{
                    PublicStaticMethodsAndData.createInfoDialog(titleText: "Please enter a Topic name atleast 2 characters long.", infoText: "", context: self)
                }
            }
        }
        
        
        let submitAnonyAction = UIAlertAction(title: "Post Anon", style: .default) { [unowned ac] _ in
        let topicInput = ac.textFields![0]
            if let topicInput = topicInput.text {
                if(topicInput.count>1){
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
    }
    
    
    
    // MARK: Data Acquisition Methods
    func startLoadingData(){
        if let uniDomain = self.thisUserProfile["uni_domain"] as? String{
            self.baseDatabaseReference.collection("universities").document(uniDomain)
                .collection("topics").document("all").getDocument { (document, error) in
                    if let document = document, document.exists, let data = document.data() {
                        self.allTopicIdNamePairs = data
                        self.initializeData()
                    }
                    else {
                        print("Document 'all' does not exist (Board)")
                    }
            }
        }
    }
    
    //loading all the topic id's and names into my giant list that holds all the topics
    func initializeData(){
        if (allTopicIdNamePairs.count >= 0){
            for(id, name) in allTopicIdNamePairs{
                self.allTopics.append(Topic(id: id,name: name as! String))
            }
            self.topicCollectionView.reloadData()
        }
    }
    
    //called externally from main under mainTabController
    func updateProfile(updatedProfile: Dictionary<String, Any>){
        self.thisUserProfile = updatedProfile
//        if(!dataLoaded){ //*option two, the UI's initiated but the data hasn't been loaded yet (because the user profile was nil during the UI setup)
////            startLoadingData()
//        }
    }
    
    
    
    //MARK: Collection View Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allTopics.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let topicCell = collectionView.dequeueReusableCell(withReuseIdentifier: topicCollectionIdentifier, for: indexPath) as! TopicCollectionViewCell
        
        topicCell.textView.text = allTopics[indexPath.item].getName()
        
        //TODO: populate the topic cell with the title of the topic
        return topicCell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSize = CGSize(width: 140, height: 140)
        return cellSize
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) { //on click of the event, pass the data from the event through a segue to the event.swift page
        if self.allTopics.count >= 0 {
            self.IDtopicClicked = self.allTopics[indexPath.item].getID()   //use currentley clicked index to get topic id
            self.performSegue(withIdentifier: "boardToTopicSegue" , sender: self) //pass data over to
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //called every single time a segue is called
        if segue.identifier == "boardToTopicSegue" {
            let vc = segue.destination as! BoardTopic
            vc.topicID = self.IDtopicClicked
            vc.thisUserProfile = self.thisUserProfile
        }
//        self.tabBarController?.tabBar.isHidden = true
    }
    
    

}



