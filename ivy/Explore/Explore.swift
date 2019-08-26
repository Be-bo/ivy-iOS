//
//  Explore.swift
//  ivy
//
//  Created by Robert on 2019-07-28.
//  Copyright © 2019 ivy social network. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

class Explore: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {


    private let baseDatabaseReference = Firestore.firestore()                    //reference to the database
    private let baseStorageReference = Storage.storage()                         //reference to storage
    
    private var thisUserProfile = Dictionary<String, Any>()
    private var allEvents = [Dictionary<String, Any>]()                          //array of dictionaries for holding each seperate event
    private var eventClicked = Dictionary<String, Any>()                         //actual event that was clicked
    
    @IBOutlet weak var eventsCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationBar()
        setUp()
    }
    
    private func setUp(){
        eventsCollectionView.delegate = self
        eventsCollectionView.dataSource = self
        eventsCollectionView.register(UINib(nibName: "EventCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "EventCollectionViewCell")
        updateProfile(updatedProfile: self.thisUserProfile) //load the profile then call setup from there
    }
    
    private func setUpNavigationBar(){
        let titleImgView = UIImageView(image: UIImage.init(named: "ivy_logo"))
        titleImgView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        titleImgView.contentMode = .scaleAspectFit
        navigationItem.titleView = titleImgView
        // this retarded bs is not working
        let settingsBtn = SettingsButton()
        let settingsButton = UIBarButtonItem(customView: settingsBtn)
        navigationItem.rightBarButtonItem = settingsButton
    }
    
    func updateProfile(updatedProfile: Dictionary<String, Any>){
        self.thisUserProfile = updatedProfile
        if (!self.thisUserProfile.isEmpty){ //make sure user profile exists
            self.loadEvents()
        }
    }
    
    // MARK: Collection View Delegate and Datasource Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allEvents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let eventCard = collectionView.dequeueReusableCell(withReuseIdentifier: "EventCollectionViewCell", for: indexPath) as! EventCollectionViewCell
        eventCard.setUp(event: allEvents[indexPath.item])

        return eventCard
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize { //item size has to adjust based on current collection view dimensions (90% of the its size, the rest is padding - see the setUp() function)
        let cellSize = CGSize(width: self.eventsCollectionView.frame.size.width * 0.50, height: self.eventsCollectionView.frame.size.height * 0.50)
        return cellSize
    }
    
    
    //TODO: deal with clicking of the events so that it responds to the right event being clicked on each time, right now it always registers the last clicked item????
    //on click of the event, pass the data from the event through a segue to the event.swift page
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        self.eventClicked = self.allEvents[indexPath.item]   //use currentley clicked index to get conversation id
        self.performSegue(withIdentifier: "exploreToEventPageSegue" , sender: self) //pass data over to
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //called every single time a segue is called
        let vc = segue.destination as! Event
        vc.event = self.eventClicked
//        vc.eventID = self.eventClicked["id"] as! String
        vc.userProfile = self.thisUserProfile
//        self.baseDatabaseReference.collection("universities").document(self.eventClicked["uni_domain"] as! String).collection("events").document(self.eventClicked["id"] as! String).updateData(["views": FieldValue.arrayUnion([Date().millisecondsSince1970])]) //log a view for the event
    }
    
    
    
    
    // MARK: Collection View Behavior Functions
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let collectionViewCenterX = self.eventsCollectionView.center.x //get the center of the collection view
        
        for cell in self.eventsCollectionView.visibleCells {
            let basePosition = cell.convert(CGPoint.zero, to: self.view)
            let cellCenterX = basePosition.x + self.eventsCollectionView.frame.size.width / 2.0 //get the center of the current cell
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
    
    
    
    //load all the events except for the featured event
    func loadEvents(){
        self.baseDatabaseReference.collection("universities").document(self.thisUserProfile["uni_domain"] as! String).collection("events").order(by: "time_millis", descending: true).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    if (!document.data().isEmpty){
                        var event = document.data()
                        let isFeatured = event["is_featured"] as! Bool
                        let isActive = event["is_active"] as! Bool
                        let endTime = event["end_time"] as! Int64
                        if (!isFeatured && isActive && endTime > Date().millisecondsSince1970 ){
                            self.allEvents.append(event)
                        }
                    }
                }
                self.eventsCollectionView.reloadData()
            }
        }
    }
    
    
    
    
    
    
}
